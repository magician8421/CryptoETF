// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.28;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/ICryptoETFToken.sol";

contract CryptoETFToken is ERC20,ICryptoETFToken {
    using SafeERC20 for IERC20;
    string public  tokenUri;

    //Constitunent array to store Constitunent Config
    Constitunent[] public   constitunents; 
    //related contracts
    address public rebalancer;
    address public router;

    //reserves of each constitunents
    mapping(address=>uint256) public constitunentsReserves;

    //_totalConstitunentDistribution
    uint24 private _totalConstitunentDistribution;


    modifier onlyRouter{
        require(msg.sender==router,"only router can execute");
        _;
    }
    
    modifier onlyRebalancer{
        if(totalSupply()!=0){
            require(msg.sender==router,"only reblancer can execute");
        }
        _;
    }


    constructor(string memory name,string memory symbol,string  memory _tokenUri,Constitunent[] memory constitunents_,address router_,address rebalancer_) ERC20(name,symbol)  {
            tokenUri=_tokenUri;
            _modifyConsitunent(constitunents_);
            router=router_;
            rebalancer=rebalancer_;
        
    }

    function getConstitunents() external view returns(Constitunent[] memory,uint24){
        return (constitunents,_totalConstitunentDistribution);
    }

    /**
     *  constitunents token : msg.sender-> etf
     *  etf mint to to
     */
    function mint(uint256 etfAmount,address to,address[] calldata tokens, uint256[] calldata amounts) external  onlyRouter{
        require(etfAmount>0,"eft amout need greater than zero");
        require(to!=address(0),"mint to can not be zero");
        require(tokens.length==constitunents.length,"tokens list token need match consitutents");
        require(amounts.length==constitunents.length,"tokens list amounts need match consitutents");
         //transfer token to cyptoetftoken
         for(uint i=0;i<tokens.length;i++){
            constitunentsReserves[tokens[i]]+=amounts[i];
            //constitunents token already have been sended to etf
           // IERC20(tokens[i]).safeTransferFrom(msg.sender,address(this), amounts[i]);
         }
        _mint(to, etfAmount);
    }

    /**
     *  constitunents token : etf-> msg.sender
     *  etf mint to to
     */
    function burn(uint256 etfAmount,address from) external onlyRouter{
        require(etfAmount>0,"eft amout need greater than zero");
        require(from!=address(0),"burn address can not be zero");
         //transfer token to cyptoetftoken
        for(uint i=0;i<constitunents.length;i++){
             Constitunent memory _cons=constitunents[i];
             //caculate token amout= tokenAmount*etfAmount/totalSupply()
             uint256 _tokenAmount=constitunentsReserves[_cons.tokenAddress]*etfAmount/totalSupply();
             //etf->msg.sender(router)
             IERC20(_cons.tokenAddress).safeTransfer(msg.sender, _tokenAmount);
         }
        _burn(from, etfAmount);
    }

    function modifyConsitunent(Constitunent[] calldata constitunents_) external onlyRebalancer  {
      
        _modifyConsitunent(constitunents_);
    }
      

    function _modifyConsitunent(Constitunent[] memory constitunents_) private {

         require(constitunents_.length>0,"constitunents can not be empty");
         for(uint256 i=0;i<constitunents_.length;i++){
                Constitunent memory _cons=constitunents_[i];
                require(_cons.tokenAddress!=address(0),"constitunent token address can not be zero");
                require(_cons.distribution>0,"constitunent token distribution must greater than zero");
                 _totalConstitunentDistribution+=_cons.distribution;
                constitunents.push(_cons);
        }
    }




}
