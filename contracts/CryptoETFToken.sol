// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.28;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "contracts/CryptoETFLibrary.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract CryptoETFToken is ERC20 {
    using CryptoETFLibrary for CryptoETFLibrary.Constitunent;
    using SafeERC20 for IERC20;
    string public  tokenUri;

    //Constitunent array to store Constitunent Config
    CryptoETFLibrary.Constitunent[] public   constitunents; 
    uint24 private _totalConstitunentDistribution;

    //related contracts
    address rebalancer;
    address router;


    modifier onlyRouter{
        require(msg.sender==router,"only router can execute");
        _;
    }
    
    modifier onlyRebalancer{
        require(msg.sender==router,"only reblancer can execute");
        _;
    }



 

    constructor(string memory name,string memory symbol,string  memory _tokenUri,CryptoETFLibrary.Constitunent[] memory constitunents_,address router_,address rebalancer_) ERC20(name,symbol)  {
            tokenUri=_tokenUri;
            _modifyConsitunent(constitunents_);
            router=router_;
            rebalancer=rebalancer_;
        
    }

    function getConstitunents() external view returns(CryptoETFLibrary.Constitunent[] memory,uint24){
        return (constitunents,_totalConstitunentDistribution);
    }

    function mint(uint256 etfAmount,address to) external   onlyRouter{
        require(etfAmount>0,"eft amout need greater than zero");
        require(to!=address(0),"mint to can not be zero");
         //transfer token to cyptoetftoken
         for(uint i=0;i<constitunents.length;i++){
             CryptoETFLibrary.Constitunent memory _cons=constitunents[i];
             //caculate token amout
             uint256 _tokenAmount=etfAmount*_cons.distribution/_totalConstitunentDistribution;
             IERC20(_cons.tokenAddress).transferFrom(to,address(this), _tokenAmount);
         }
        _mint(to, etfAmount);
    }

    function burn(uint256 etfAmount,address benificial) external onlyRouter{
        require(etfAmount>0,"eft amout need greater than zero");
        require(benificial!=address(0),"mint to can not be zero");
         //transfer token to cyptoetftoken
        for(uint i=0;i<constitunents.length;i++){
             CryptoETFLibrary.Constitunent memory _cons=constitunents[i];
             //caculate token amout
             uint256 _tokenAmount=etfAmount*_cons.distribution/_totalConstitunentDistribution;
             IERC20(_cons.tokenAddress).transfer(benificial, _tokenAmount);
         }
        _burn(benificial, etfAmount);
    }

    function modifyConsitunent(CryptoETFLibrary.Constitunent[] memory constitunents_) external onlyRebalancer  {
        require(totalSupply()==0,"consituent only can be modified when totalsupply is zero");
        _modifyConsitunent(constitunents_);
    }
      

    function _modifyConsitunent(CryptoETFLibrary.Constitunent[] memory constitunents_) private {

         require(constitunents_.length>0,"constitunents can not be empty");
         for(uint256 i=0;i<constitunents_.length;i++){
                CryptoETFLibrary.Constitunent memory _cons=constitunents_[i];
                require(_cons.tokenAddress!=address(0),"constitunent token address can not be zero");
                require(_cons.distribution>0,"constitunent token distribution must greater than zero");
                 _totalConstitunentDistribution+=_cons.distribution;
                constitunents.push(_cons);
        }
    }


    // function mint(uint256 etfAmount,address to,CryptoETFLibrary.TokenDistribution[] memory distributions_) internal  onlyRouter{
    //     require(distributions_.length>0,"distributions_ can not be empty");
    //     require(to!=address(0),"mint to can not be zero");
    //      //transfer token to cyptoetftoken
    //     for(uint i=0;i<distributions_.length;i++){
    //         CryptoETFLibrary.TokenDistribution memory _distribution=distributions_[i];
    //         IERC20(_distribution.tokenAddress).safeTransferFrom(to,address(this), _distribution.distributionAmount);
    //     }
    //     _mint(to, etfAmount);
    // }


    // function burn(uint256 etfAmount,address benificial,CryptoETFLibrary.TokenDistribution[] memory distributions_) external onlyRouter{
    //     require(distributions_.length>0,"distributions_ can not be empty");
    //     require(benificial!=address(0),"mint to can not be zero");
    //      //transfer token to cyptoetftoken
    //     for(uint i=0;i<distributions_.length;i++){
    //         CryptoETFLibrary.TokenDistribution memory _distribution=distributions_[i];
    //         IERC20(_distribution.tokenAddress).transfer(benificial, _distribution.distributionAmount);
    //     }
    //     _burn(benificial, etfAmount);
    // }




}
