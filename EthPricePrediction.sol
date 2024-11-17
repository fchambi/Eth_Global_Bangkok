// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

/**
 * @title EthPricePrediction
 * @notice Contrato de predicción del precio ETH/USD con un pool diario de apuestas.
 */
contract EthPricePrediction {
    /// @notice El oráculo Chronicle ETH/USD.
    IChronicle public immutable chronicle;

    /// @notice El gestor de acceso a los oráculos Chronicle.
    ISelfKisser public immutable selfKisser;

    /// @notice Dirección del propietario del contrato.
    address public owner;

    /// @notice Mapeo para almacenar predicciones por participante.
    mapping(address => uint256) public predictions;

    /// @notice Monto total apostado en el pool.
    uint256 public totalPool;

    /// @notice Dirección del ganador del día.
    address public dailyWinner;

    /// @notice Registro de predicciones diarias.
    address[] public participants;

    /// @notice Marca de tiempo del inicio del día actual.
    uint256 public dayStart;

    /// @notice Evento para registrar nuevas predicciones.
    event NewPrediction(address indexed participant, uint256 prediction);

    /// @notice Evento para anunciar al ganador.
    event WinnerAnnounced(address indexed winner, uint256 reward);

    /// @notice Modificador para restringir acceso al propietario.
    modifier onlyOwner() {
        require(msg.sender == owner, "Solo el owner puede llamar esta funcion");
        _;
    }

    constructor(address chronicle_, address selfKisser_) {
        chronicle = IChronicle(chronicle_);
        selfKisser = ISelfKisser(selfKisser_);
        selfKisser.selfKiss(address(chronicle));

        // Establecer el propietario como el desplegador del contrato.
        owner = msg.sender;

        // Iniciar el día actual.
        dayStart = block.timestamp;
    }

    /// @notice Permite a los participantes hacer una predicción.
    /// @param prediction El precio ETH/USD predicho por el participante.
    function makePrediction(uint256 prediction) external payable {
        require(msg.value > 0, "Debe enviar ETH para participar");
        require(
            block.timestamp < dayStart + 1 days,
            "El tiempo para hacer predicciones ha terminado"
        );

        // Registrar la predicción.
        predictions[msg.sender] = prediction;
        participants.push(msg.sender);

        // Actualizar el pozo.
        totalPool += msg.value;

        emit NewPrediction(msg.sender, prediction);
    }

    /// @notice Finaliza el día, calcula el ganador y distribuye el premio.
    function finalizeDay() external {
        require(
            block.timestamp >= dayStart + 1 days
        );
        _calculateWinner();
    }

    /// @notice Permite al propietario seleccionar al ganador de inmediato.
    function selectWinnerImmediately() external onlyOwner {
        _calculateWinner();
    }

    /// @notice Calcula el ganador y distribuye el premio.
    function _calculateWinner() private {
        require(participants.length > 0, "No hay participantes");

        // Obtener el precio actual del oráculo.
        uint256 oraclePrice = chronicle.read();

        // Determinar al ganador.
        uint256 closestDifference = type(uint256).max;
        address winner;

        for (uint256 i = 0; i < participants.length; i++) {
            address participant = participants[i];
            uint256 prediction = predictions[participant];
            uint256 difference = _absoluteDifference(prediction, oraclePrice);

            if (difference < closestDifference) {
                closestDifference = difference;
                winner = participant;
            }
        }

        // Actualizar variables del estado.
        dailyWinner = winner;
        uint256 reward = (totalPool * 90) / 100; // El ganador recibe el 90% del pozo.

        // Transferir el premio al ganador.
        payable(winner).transfer(reward);

        emit WinnerAnnounced(winner, reward);

        // Reiniciar para el siguiente día.
        _resetDay();
    }

    /// @notice Calcula la diferencia absoluta entre dos números.
    function _absoluteDifference(uint256 a, uint256 b)
        private
        pure
        returns (uint256)
    {
        return a > b ? a - b : b - a;
    }

    /// @notice Reinicia las variables para un nuevo día.
    function _resetDay() private {
        for (uint256 i = 0; i < participants.length; i++) {
            delete predictions[participants[i]];
        }

        delete participants;
        totalPool = 0;
        dayStart = block.timestamp;
    }

    /// @notice Permite al propietario transferir la propiedad del contrato.
    /// @param newOwner Dirección del nuevo propietario.
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Nuevo propietario invalido");
        owner = newOwner;
    }
        function read() external view returns (uint256 val) {
        return chronicle.read();
    }
}

// Interfaces existentes.
interface IChronicle {
    function read() external view returns (uint256 value);
}

interface ISelfKisser {
    function selfKiss(address oracle) external;
}
