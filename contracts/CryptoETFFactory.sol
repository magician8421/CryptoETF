// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;
import "./CryptoETFToken.sol";
import "./CryptoETFRouter.sol";
/**
 * @title CryptoETFTokenFactory
 * @author wayne.tong
 * @notice 
 */
contract CryptoETFTokenFactory{

    address  public router;
    address  public rebalancer;
    mapping(string=>address) public  etfListM;
    //all the etfs address 
    address[] public  etfs;
    //how many etf have been created by factory
    uint256  public  totalEtf;

    event ETFCREATED(string indexed,address );
    constructor(address _router,address _rebalancer){
        router=_router;
        rebalancer=_rebalancer;
    }
    /**
     * factory method to create etf 
     * token with a sepecific symbole can only be created once
     * @param name  name 
     * @param symbol symbol unqiue
     * @param tokenUri  tokenUri
     * @param constitunents constitunents token of etf
     * @return etfAddress
     */
    function createETF(string memory name,string memory symbol,string  memory tokenUri,CryptoETFToken.Constitunent[] memory constitunents) external returns(address){
        require(bytes(name).length>0,"name must not be blank");
        require(bytes(symbol).length>0,"symbol must not be blank");
        require(constitunents.length>0,"constitunents_ must not be blank");
        require(etfListM[symbol]==address(0),"etf with this symbol is already exsit");
        address etf= address(new CryptoETFToken(name,symbol,tokenUri,constitunents,address(router),rebalancer));
        etfListM[symbol]=etf;
        etfs.push(etf);
        emit ETFCREATED(symbol,etf);
        totalEtf++;
        return etf;
    }

}