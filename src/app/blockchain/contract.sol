pragma solidity >=0.8.0 <0.10.0;

contract contractMomos 
{
    /* declarations (no memory usage) */
    struct niggaFeetData {
        uint256 dateCreation;
        address sender;
        uint256 amount;
        bytes32 tokenHash;
        bool isSent;
    }



    /* se ejecutará cuando se deploye el contrato */
    constructor() {
        // constructor code here    
    }

    /* storage variables (permanent)*/
    // mapping(bytes32 => niggaFeetData) public niggaFeetDatas;

    /* memory variables */
}