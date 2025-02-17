// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;
import "./CryptoETFToken.sol";
import "./CryptoETFRouter.sol";
contract CryptoETFTokenFactory{

    address  public router;
    address  public rebalancer;
    mapping(string=>address) public  etfListM;
    address[] public  etfs;

    event ETFCREATED(string indexed,address );
    constructor(address _router,address _rebalancer){
        router=_router;
        rebalancer=_rebalancer;
    }
    function createETF(string memory name,string memory symbol,string  memory tokenUri,CryptoETFToken.Constitunent[] memory constitunents) external returns(address){
        require(bytes(name).length>0,"name must not be blank");
        require(bytes(symbol).length>0,"symbol must not be blank");
        require(constitunents.length>0,"constitunents_ must not be blank");
        require(etfListM[symbol]==address(0),"etf with this symbol is already exsit");
        address etf= address(new CryptoETFToken(name,symbol,tokenUri,constitunents,address(router),rebalancer));
        etfListM[symbol]=etf;
        etfs.push(etf);
        emit ETFCREATED(symbol,etf);
        return etf;
    }

}