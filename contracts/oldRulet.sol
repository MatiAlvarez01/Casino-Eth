//SPDX-License-Identifier: MatiAlvarez21
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/*
    Que el Casino tenga su propia moneda (CTN).
    Todas las apuestas en el casino se hacen con esa moneda.
    Los usuarios deberan comprar esa moneda antes de podes jugar.
    Los premios se pagan en esa moneda.
    Los funds estan en esa moneda.
    Luego podran retirar fondos en esa moneda.
    PROBLEMA: No se como hacer para asignarle un valor a la compra de CTN. 
*/

contract RuletaOld {
    address payable casinoOwner;
    uint funds;

    //Constructor
    constructor(address payable _owner) {
        casinoOwner = _owner;
    }

    //Tipo de apuesta
    enum BetType {
        ParInpar,
        RojoNegro,
        Pleno
    }

    //Listar el Token del Casino
    struct Token {
        uint id;
        bytes32 ticker;
        address tokenAddress;
    }
    mapping(bytes32 => Token) public tokens;
    bytes32[] public tokenList;
    uint public nextTokenId;

    //Tener un listado de las apuestas
    struct Bet {
        uint id;
        bytes32 ticker;
        uint amount;
        address payable owner;
        BetType betType;
    }
    mapping(address => Bet) public bets;
    Bet[] public betList;
    uint public nextBetId;

    //El usuario puede ver sus fondos
    mapping(bytes32 => mapping(bytes32 => uint)) public traderBalances;

    //Linkear la moneda del Casino con el contrato
    function linkToken(bytes32 ticker, address tokenAddress) external {
        tokens[ticker] = Token(
            nextTokenId,
            ticker,
            tokenAddress
        );
        tokenList.push(ticker);
        nextTokenId++;
    }

    //Que el postor pueda comprar el token del casino
    function buyToken(uint amount, bytes32 ticker) external {
        IERC20(tokens[ticker].tokenAddress).transfer(msg.sender, amount);
        funds += amount;
    }

    //Funcion para recibir apuestas
    function placeBet(bytes32 ticker, uint amount, address payable betOwner, BetType betType) external onlyCtn(ticker) {
        //Creamos la apuesta
        Bet memory newBet = Bet(
            nextBetId,
            ticker,
            amount,
            betOwner,
            betType
        );
        bets[betOwner] = newBet;
        nextBetId++;
        //Depositamos los fondos en el contrato
        IERC20(tokens[ticker].tokenAddress).transferFrom(msg.sender, address(this), amount);
        funds += amount;
    }

    //Si hay ganador
    function winner(address winnerAddress) external {
        Bet memory winnerBet = bets[winnerAddress];

        if (winnerBet.betType == BetType.ParInpar || winnerBet.betType == BetType.RojoNegro) {
            uint amount = winnerBet.amount * 2;
            winnerBet.owner.transfer(amount);
            funds -= amount;
        }
        if (winnerBet.betType == BetType.Pleno) {
            uint amount = winnerBet.amount * 36;
            winnerBet.owner.transfer(amount);
            funds -= amount;
        }
    }

    //El dueño del casino podrá depositar fondos
    function deposit(uint amount, bytes32 ticker) external onlyCasinoOwner() onlyCtn(ticker) {
        IERC20(tokens[ticker].tokenAddress).transferFrom(msg.sender, address(this), amount);
        funds += amount;
    }
    //El dueño del casino podrá retirar fondos
    function withdraw(uint amount, bytes32 ticker) external onlyCasinoOwner() onlyCtn(ticker) {
        require(funds >= amount, "Funds too low");
        IERC20(tokens[ticker].tokenAddress).transfer(msg.sender, amount);
        funds -= amount;
    }

    receive() external payable {}

    //Verifica que sea el dueño del casino
    modifier onlyCasinoOwner() {
        require(msg.sender == casinoOwner, "Only casino owner can deposit or withdraw funds");
        _;
    }

    //Verifica que el token este permitido en el casino
    modifier onlyCtn(bytes32 ticker) {
        bool allowed = false;
        for (uint i=0; i<tokenList.length; i++) {
            if (tokenList[i] == ticker) {
                allowed = true;
            }
        }
        require(allowed = true, "Token not allowed by The Casino");
        _;
    }
}