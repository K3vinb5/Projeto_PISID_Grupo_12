-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Tempo de geração: 16-Mar-2024 às 02:17
-- Versão do servidor: 10.4.27-MariaDB
-- versão do PHP: 8.1.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Banco de dados: `grupo12_bd`
--
CREATE DATABASE IF NOT EXISTS `grupo12_bd` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
USE `grupo12_bd`;

DELIMITER $$
--
-- Procedimentos
--
DROP PROCEDURE IF EXISTS `ApagarExperiencia`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ApagarExperiencia` (IN `idExperiencia` INT)   BEGIN

	UPDATE experiência e
    SET e.RemocaoLogica = TRUE
    WHERE e.IDExperiência = idExperiencia;
    
    SELECT ROW_COUNT();

END$$

DROP PROCEDURE IF EXISTS `ApagarUtilizador`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ApagarUtilizador` (IN `email` VARCHAR(50))   BEGIN

	UPDATE utilizador u
    SET u.RemocaoLogica = TRUE
    WHERE u.EmailUtilizador = email;
    
    SELECT ROW_COUNT();
    
END$$

DROP PROCEDURE IF EXISTS `AtribuirExperiênciaInvestigador`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `AtribuirExperiênciaInvestigador` (IN `idExperiencia` INT, IN `idInvestigador` INT)   BEGIN

	DECLARE countExp, countUti, idExperienciaDecorrer INT;

    SELECT COUNT(*) INTO countExp FROM experiência e WHERE e.IDExperiência = idExperiencia;
    SELECT COUNT(*) INTO countUti FROM utilizador u WHERE u.IDUtilizador = idInvestigador;
	
    IF countExp>0 AND countUti>0 THEN
    	CALL ObterExperienciaADecorrer(idExperienciaDecorrer);
        IF idExperienciaDecorrer != idExperiencia THEN
        	UPDATE experiência e
            SET e.Investigador = idInvestigador
            WHERE e.IDExperiência = idExperiencia;
		END IF;
	END IF;
    
    SELECT ROW_COUNT();
    
END$$

DROP PROCEDURE IF EXISTS `AtualizarNumRatosSala`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `AtualizarNumRatosSala` (IN `salaOrigem` INT, IN `salaDestino` INT, IN `idExperiencia` INT)   BEGIN

	DECLARE valorOrigem, valorDestino INT;
    SELECT m.NúmeroRatosFinal INTO valorOrigem FROM mediçõessalas m WHERE m.IDExperiência = idExperiencia AND m.Sala = salaOrigem LIMIT 1;
    SELECT m.NúmeroRatosFinal INTO valorDestino FROM mediçõessalas m WHERE m.IDExperiência = idExperiencia AND m.Sala = salaDestino LIMIT 1;
    
	UPDATE mediçõessalas
    SET NúmeroRatosFinal = (valorOrigem - 1)
    WHERE Sala = salaOrigem AND IDExperiência = idExperiencia;
    
    UPDATE mediçõessalas
    SET NúmeroRatosFinal = (valorDestino + 1)
    WHERE Sala = salaDestino AND IDExperiência = idExperiencia;

END$$

DROP PROCEDURE IF EXISTS `ComecarTerminarExperienca`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ComecarTerminarExperienca` (IN `idExperiencia` INT)   BEGIN

	DECLARE idExperienciaDecorrer INT;
    CALL ObterExperienciaADecorrer(idExperiencia);
    
    IF idExperienciaDecorrer IS NULL THEN
    	UPDATE experiência e
        SET e.DataHoraInicioExperiência = NOW()
        WHERE e.IDExperiência = idExperiencia;
	ELSE
    	IF idExperiencia = idExperienciaDecorrer THEN
        	UPDATE experiência e
            SET e.DataHoraFimExperiência = NOW()
            WHERE e.IDExperiência = idExperiencia;
		END IF;
	END IF;
    
END$$

DROP PROCEDURE IF EXISTS `EditarExperiencia`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `EditarExperiencia` (IN `descricao` TEXT, IN `numeroRatos` INT, IN `limiteRatosSala` INT, IN `segSemMovimento` INT, IN `temperaturaMinima` DECIMAL(4,2), IN `temperaturaMaxima` DECIMAL(4,2), IN `toleranciaTemperatura` DECIMAL(4,2), IN `snoozeTime` INT, IN `idExperiencia` INT)   BEGIN

	DECLARE idExperienciaDecorrer INT;
    CALL ObterExperienciaADecorrer(idExperienciaDecorrer);
    
    IF idExperiencia = idExperienciaDecorrer THEN
    	UPDATE experiência e
        SET e.Descrição = IFNULL(descricao, e.Descrição)
        WHERE e.IDExperiência = idExperiencia;
	ELSE
    	IF numeroRatos>0 AND limiteRatosSala>0 AND segSemMovimento>0 AND toleranciaTemperatura>0 AND snoozeTime>0 AND temperaturaMaxima>temperaturaMinima THEN
            UPDATE experiência e
            SET e.Descrição = IFNULL(descricao, e.Descrição), 
                e.NúmeroRatos = IFNULL(numeroRatos, e.NúmeroRatos), 
                e.LimiteRatosSala = IFNULL(limiteRatosSala, e.LimiteRatosSala), 
                e.SegundosSemMovimento = IFNULL(segSemMovimento, e.SegundosSemMovimento), 
                e.TemperaturaMinima = IFNULL(temperaturaMinima, e.TemperaturaMinima), 
                e.TemperaturaMaxima = IFNULL(temperaturaMaxima, e.TemperaturaMaxima), 
                e.TolerânciaTemperatura = IFNULL(toleranciaTemperatura, e.TolerânciaTemperatura), 
                e.SnoozeTime = IFNULL(snoozeTime, e.SnoozeTime)
            WHERE e.IDExperiência = idExperiencia;
        END IF;
	END IF;
    	

END$$

DROP PROCEDURE IF EXISTS `EditarUtilizador`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `EditarUtilizador` (IN `idInvestigador` INT, IN `email` VARCHAR(50), IN `nome` VARCHAR(100), IN `telefone` VARCHAR(12), IN `password` VARCHAR(100))   BEGIN

	IF email IS NOT NULL THEN
    	UPDATE utilizador u
        SET u.EmailUtilizador = email
        WHERE u.IDUtilizador = idInvestigador;
	END IF;
    
    IF nome IS NOT NULL THEN
    	UPDATE utilizador u
        SET u.NomeUtilizador = nome
        WHERE u.IDUtilizador = idInvestigador;
	END IF;
    
    IF telefone IS NOT NULL THEN
    	UPDATE utilizador u
        SET u.TelefoneUtilizador = telefone
        WHERE u.IDUtilizador = idInvestigador;
	END IF;
    
    IF password IS NOT NULL THEN        
    	UPDATE utilizador u
        SET u.PasswordUtilizador = AES_ENCRYPT(password, 'grupo12_bd')
        WHERE u.IDUtilizador = idInvestigador;
	END IF;
    
    SELECT ROW_COUNT();

END$$

DROP PROCEDURE IF EXISTS `IniciarSala`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `IniciarSala` (IN `idExperiencia` INT, IN `numeroRatos` INT, IN `sala` INT)   BEGIN

	INSERT INTO mediçõessalas (IDExperiência, NúmeroRatosFinal, Sala)
	VALUES (idExperiencia, numeroRatos, numeroRatos);
    
    SELECT ROW_COUNT();

END$$

DROP PROCEDURE IF EXISTS `InserirAlerta`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `InserirAlerta` (IN `sala` INT, IN `sensor` INT, IN `leitura` DECIMAL(4,2), IN `tipoAlerta` VARCHAR(100), IN `mensagem` VARCHAR(100))   BEGIN

	DECLARE idExperiencia INT;
    CALL ObterExperienciaADecorrer(idExperiencia);

	IF sala IS NOT NULL THEN
    	INSERT INTO alerta (DataHora, Sala, TipoAlerta, Mensagem, IDExperiência) 
        VALUES (NOW(), sala, tipoAlerta, mensagem, idExperiencia);
    ELSEIF sensor IS NOT NULL AND leitura IS NOT NULL THEN
    	INSERT INTO alerta (DataHora, Sensor, Leitura, TipoAlerta, Mensagem, IDExperiência) 
        VALUES (NOW(), sensor, leitura, tipoAlerta, mensagem, idExperiencia);
	END IF;
    
    SELECT ROW_COUNT();

END$$

DROP PROCEDURE IF EXISTS `InserirExperiência`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `InserirExperiência` (IN `descricao` TEXT, IN `idInvestigador` INT, IN `numeroRatos` INT, IN `limiteRatosSala` INT, IN `segSemMovimento` INT, IN `temperaturaMinima` DECIMAL(4,2), IN `temperaturaMaxima` DECIMAL(4,2), IN `toleranciaTemperatura` DECIMAL(4,2), IN `snoozeTime` INT)   BEGIN

	DECLARE counter, idExperiencia INT;
	IF numeroRatos>0 AND limiteRatosSala>0 AND segSemMovimento>0 AND toleranciaTemperatura>0 AND snoozeTime>0 AND temperaturaMaxima>temperaturaMinima THEN
    	INSERT INTO utilizador (Descrição, Investigador, DataHoraCriaçãoExperiência, NúmeroRatos, LimiteRatosSala, SegundosSemMovimento, TemperaturaMinima, TemperaturaMaxima, TolerânciaTemperatura, SnoozeTime)
        VALUES (descricao, idInvestigador, NOW(), numeroRatos, limiteRatosSala, segSemMovimento, temperaturaMinima, temperaturaMaxima, toleranciaTemperatura, snoozeTime);
        SELECT LAST_INSERT_ID() AS idExperiencia;

        SET counter = 1;
        CALL IniciarSala(idExperiencia, numeroRatos, counter);
        WHILE counter <= 10 DO
            CALL IniciarSala(idExperiencia, 0, counter);
            SET counter = counter + 1;
        END WHILE;
    END IF;
    
    SELECT ROW_COUNT();

END$$

DROP PROCEDURE IF EXISTS `InserirMovimento`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `InserirMovimento` (IN `dataHora` DATETIME, IN `salaOrigem` INT, IN `salaDestino` INT, IN `idMongo` INT)   BEGIN

    DECLARE idExperiencia INT;
    CALL ObterExperienciaADecorrer(idExperiencia);

    INSERT INTO mediçõespassagens (DataHora, SalaOrigem, SalaDestino, IDExperiencia, IDMongo)
    VALUES (dataHora, salaOrigem, salaDestino, idExperiencia, idMongo);
    
    CALL AtualizarNumRatosSala(salaOrigem, salaDestino, idExperiencia);

    SELECT ROW_COUNT(); -- 0- means no rows affected

END$$

DROP PROCEDURE IF EXISTS `InserirTemperatura`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `InserirTemperatura` (IN `dataHora` DATETIME, IN `leitura` DECIMAL(4,2), IN `sensor` INT, IN `idMongo` VARCHAR(50))   BEGIN

    DECLARE idExperiencia INT;
    CALL ObterExperienciaADecorrer(idExperiencia);

    INSERT INTO mediçõestemperatura (DataHora, Leitura, Sensor, IDExperiencia, IDMongo)
    VALUES (dataHora, leitura, sensor, idExperiencia, idMongo);

    SELECT ROW_COUNT(); -- 0- means no rows affected/nothing inserted 
                      -- 1- means your row has been inserted successfully

END$$

DROP PROCEDURE IF EXISTS `InserirUtilizador`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `InserirUtilizador` (IN `email` VARCHAR(50), IN `nome` VARCHAR(100), IN `tipoUtilizador` VARCHAR(50), IN `telefone` VARCHAR(12))   BEGIN

	Declare Encrypt varbinary(200);
    SET Encrypt = AES_ENCRYPT('Pass123!', 'grupo12_bd');

    INSERT INTO utilizador (NomeUtilizador, TelefoneUtilizador, TipoUtilizador, EmailUtilizador, PasswordUtilizador)
    VALUES (nome, telefone, tipoUtilizador, email, Encrypt);
    
    SELECT ROW_COUNT();

END$$

DROP PROCEDURE IF EXISTS `ObterExperiencia`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ObterExperiencia` (IN `idExperiencia` INT)   BEGIN

	SELECT * FROM experiência e WHERE e.IDExperiência = idExperiencia;
    
END$$

DROP PROCEDURE IF EXISTS `ObterExperienciaADecorrer`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ObterExperienciaADecorrer` ()   BEGIN

    SELECT IDExperiência FROM v_expadecorrer LIMIT 1;
    
END$$

DROP PROCEDURE IF EXISTS `ObterInfoUtilizador`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ObterInfoUtilizador` (IN `idUtilizador` INT)   BEGIN

	SELECT * FROM utilizador u WHERE u.IDUtilizador = idUtilizador;
    
END$$

DROP PROCEDURE IF EXISTS `ObterListaExperiencias`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ObterListaExperiencias` ()   BEGIN

	SELECT * FROM experiência;

END$$

DROP PROCEDURE IF EXISTS `ObterPassagensExperiencia`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ObterPassagensExperiencia` (IN `idExperiencia` INT)   BEGIN

	SELECT * FROM mediçõespassagens m WHERE m.IDExperiência = idExperiencia;
    
END$$

DROP PROCEDURE IF EXISTS `ObterRatosSalasExperiencia`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ObterRatosSalasExperiencia` (IN `idExperiencia` INT)   BEGIN

	SELECT * FROM mediçõessalas m WHERE m.IDExperiência = idExperiencia;
    
END$$

DROP PROCEDURE IF EXISTS `ObterTemperaturasExperiencia`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ObterTemperaturasExperiencia` (IN `idExperiencia` INT)   BEGIN

	SELECT * FROM mediçõestemperatura m WHERE m.IDExperiência = idExperiencia;
    
END$$

DROP PROCEDURE IF EXISTS `ObterUtilizadores`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ObterUtilizadores` ()   BEGIN

	SELECT * FROM utilizador;
    
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `alerta`
--

DROP TABLE IF EXISTS `alerta`;
CREATE TABLE IF NOT EXISTS `alerta` (
  `IDAlerta` int(11) NOT NULL AUTO_INCREMENT,
  `DataHora` datetime NOT NULL,
  `Sala` int(11) DEFAULT NULL,
  `Sensor` int(11) DEFAULT NULL,
  `Leitura` decimal(4,2) DEFAULT NULL,
  `TipoAlerta` enum('Sem movimento','Temperatura','Capacidade da sala') NOT NULL,
  `Mensagem` varchar(100) NOT NULL,
  `IDExperiência` int(11) DEFAULT NULL,
  PRIMARY KEY (`IDAlerta`),
  KEY `ExperienciaFK` (`IDExperiência`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estrutura da tabela `experiência`
--

DROP TABLE IF EXISTS `experiência`;
CREATE TABLE IF NOT EXISTS `experiência` (
  `IDExperiência` int(11) NOT NULL AUTO_INCREMENT,
  `Descrição` text DEFAULT NULL,
  `Investigador` int(11) NOT NULL,
  `DataHoraCriaçãoExperiência` datetime NOT NULL DEFAULT current_timestamp(),
  `NúmeroRatos` int(11) NOT NULL,
  `LimiteRatosSala` int(11) NOT NULL,
  `SegundosSemMovimento` int(11) NOT NULL,
  `TemperaturaMinima` decimal(4,2) NOT NULL,
  `TemperaturaMaxima` decimal(4,2) NOT NULL,
  `TolerânciaTemperatura` decimal(4,2) NOT NULL,
  `DataHoraInicioExperiência` datetime DEFAULT NULL,
  `DataHoraFimExperiência` datetime DEFAULT NULL,
  `SnoozeTime` int(11) NOT NULL,
  `RemocaoLogica` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`IDExperiência`),
  KEY `UtilizadoresFK` (`Investigador`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Extraindo dados da tabela `experiência`
--

INSERT INTO `experiência` (`IDExperiência`, `Descrição`, `Investigador`, `DataHoraCriaçãoExperiência`, `NúmeroRatos`, `LimiteRatosSala`, `SegundosSemMovimento`, `TemperaturaMinima`, `TemperaturaMaxima`, `TolerânciaTemperatura`, `DataHoraInicioExperiência`, `DataHoraFimExperiência`, `SnoozeTime`, `RemocaoLogica`) VALUES
(1, 'Descrição Experiência', 1, '2024-02-24 23:26:18', 12, 12, 12, '12.00', '0.00', '2.00', '2024-02-21 22:26:00', '2024-02-21 22:33:00', 0, 0),
(2, 'asdasd', 1, '2024-02-25 00:55:47', 12, 12, 12, '12.00', '12.10', '12.00', '2024-02-28 23:55:48', '2024-02-21 23:55:48', 0, 0),
(3, 'asd', 1, '2024-02-25 03:02:38', 12, 12, 12, '12.00', '12.20', '12.00', '2024-02-12 03:02:12', '2024-02-13 03:02:12', 0, 0),
(4, 'descricao', 1, '2024-02-25 03:50:44', 20, 20, 20, '20.00', '1.10', '10.00', '2024-02-12 03:02:12', '2024-02-13 03:02:12', 0, 0),
(5, 'descricao', 1, '2024-02-25 03:58:18', 20, 20, 20, '20.00', '1.10', '10.00', '2024-02-12 03:02:12', '2024-02-13 03:02:12', 0, 0),
(6, 'descricao', 2, '2024-02-25 04:00:58', 20, 20, 20, '20.00', '1.10', '10.00', '2024-02-12 03:02:12', '2024-02-13 03:02:12', 0, 0),
(7, 'descricao', 1, '2024-02-25 04:06:37', 20, 20, 20, '20.00', '1.10', '10.00', '2024-02-12 03:02:12', '2024-02-13 03:02:12', 0, 0),
(8, 'descricao', 2, '2024-02-25 04:07:04', 20, 20, 20, '20.00', '1.10', '10.00', '2024-02-12 03:02:12', '2024-02-13 03:02:12', 0, 0),
(9, 'descricao', 2, '2024-02-26 15:11:01', 20, 20, 20, '20.00', '20.00', '10.00', '2024-02-12 03:02:12', '2024-02-13 03:02:12', 0, 0);

-- --------------------------------------------------------

--
-- Estrutura da tabela `mediçõespassagens`
--

DROP TABLE IF EXISTS `mediçõespassagens`;
CREATE TABLE IF NOT EXISTS `mediçõespassagens` (
  `IDMedição` int(11) NOT NULL AUTO_INCREMENT,
  `DataHora` datetime NOT NULL,
  `SalaOrigem` int(11) NOT NULL,
  `SalaDestino` int(11) NOT NULL,
  `IDExperiência` int(11) NOT NULL,
  `IDMongo` varchar(50) NOT NULL,
  PRIMARY KEY (`IDMedição`),
  UNIQUE KEY `IDMongo` (`IDMongo`),
  KEY `ExpPassagem` (`IDExperiência`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estrutura da tabela `mediçõessalas`
--

DROP TABLE IF EXISTS `mediçõessalas`;
CREATE TABLE IF NOT EXISTS `mediçõessalas` (
  `IDMedição` int(11) NOT NULL AUTO_INCREMENT,
  `IDExperiência` int(11) NOT NULL,
  `NúmeroRatosFinal` int(11) NOT NULL,
  `Sala` int(11) NOT NULL,
  PRIMARY KEY (`IDMedição`),
  KEY `ExpSalaFK` (`IDExperiência`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estrutura da tabela `mediçõestemperatura`
--

DROP TABLE IF EXISTS `mediçõestemperatura`;
CREATE TABLE IF NOT EXISTS `mediçõestemperatura` (
  `IDMedição` int(11) NOT NULL AUTO_INCREMENT,
  `DataHora` datetime NOT NULL,
  `Leitura` decimal(4,2) NOT NULL,
  `Sensor` int(11) NOT NULL,
  `IDExperiência` int(11) NOT NULL,
  `IDMongo` varchar(50) NOT NULL,
  PRIMARY KEY (`IDMedição`),
  UNIQUE KEY `IDMongo` (`IDMongo`),
  KEY `ExpTemperatura` (`IDExperiência`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estrutura da tabela `parâmetroadicionais`
--

DROP TABLE IF EXISTS `parâmetroadicionais`;
CREATE TABLE IF NOT EXISTS `parâmetroadicionais` (
  `IDParâmetro` int(11) NOT NULL AUTO_INCREMENT,
  `Designação` varchar(100) NOT NULL,
  `Valor` int(11) NOT NULL,
  PRIMARY KEY (`IDParâmetro`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estrutura da tabela `utilizador`
--

DROP TABLE IF EXISTS `utilizador`;
CREATE TABLE IF NOT EXISTS `utilizador` (
  `IDUtilizador` int(11) NOT NULL AUTO_INCREMENT,
  `NomeUtilizador` varchar(100) NOT NULL,
  `TelefoneUtilizador` varchar(12) NOT NULL,
  `TipoUtilizador` enum('Investigador','Administrador de Aplicação','System (WritemySQL)') NOT NULL,
  `EmailUtilizador` varchar(50) NOT NULL,
  `PasswordUtilizador` varbinary(200) NOT NULL,
  `RemocaoLogica` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`IDUtilizador`),
  UNIQUE KEY `EmailUtilizador` (`EmailUtilizador`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Extraindo dados da tabela `utilizador`
--

INSERT INTO `utilizador` (`IDUtilizador`, `NomeUtilizador`, `TelefoneUtilizador`, `TipoUtilizador`, `EmailUtilizador`, `PasswordUtilizador`, `RemocaoLogica`) VALUES
(1, 'admin', '987654321', '', 'admin@email.com', 0x61646d696e, 0),
(2, 'Kevin', '987654322', 'Investigador', 'kevin@email.com', 0x6b6576696e, 0),
(3, 'Investigador 1', '912345678', 'Investigador', 'investigador1@gmail.com', 0x9feb7a8a97596e9df8a464e5432ff7cf, 0);

-- --------------------------------------------------------

--
-- Estrutura stand-in para vista `v_expadecorrer`
-- (Veja abaixo para a view atual)
--
DROP VIEW IF EXISTS `v_expadecorrer`;
CREATE TABLE IF NOT EXISTS `v_expadecorrer` (
`IDExperiência` int(11)
,`Descrição` text
,`Investigador` int(11)
,`DataHoraCriaçãoExperiência` datetime
,`NúmeroRatos` int(11)
,`LimiteRatosSala` int(11)
,`SegundosSemMovimento` int(11)
,`TemperaturaMinima` decimal(4,2)
,`TemperaturaMaxima` decimal(4,2)
,`TolerânciaTemperatura` decimal(4,2)
,`DataHoraInicioExperiência` datetime
,`DataHoraFimExperiência` datetime
,`SnoozeTime` int(11)
,`RemocaoLogica` tinyint(1)
);

-- --------------------------------------------------------

--
-- Estrutura para vista `v_expadecorrer`
--
DROP TABLE IF EXISTS `v_expadecorrer`;

DROP VIEW IF EXISTS `v_expadecorrer`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_expadecorrer`  AS SELECT `experiência`.`IDExperiência` AS `IDExperiência`, `experiência`.`Descrição` AS `Descrição`, `experiência`.`Investigador` AS `Investigador`, `experiência`.`DataHoraCriaçãoExperiência` AS `DataHoraCriaçãoExperiência`, `experiência`.`NúmeroRatos` AS `NúmeroRatos`, `experiência`.`LimiteRatosSala` AS `LimiteRatosSala`, `experiência`.`SegundosSemMovimento` AS `SegundosSemMovimento`, `experiência`.`TemperaturaMinima` AS `TemperaturaMinima`, `experiência`.`TemperaturaMaxima` AS `TemperaturaMaxima`, `experiência`.`TolerânciaTemperatura` AS `TolerânciaTemperatura`, `experiência`.`DataHoraInicioExperiência` AS `DataHoraInicioExperiência`, `experiência`.`DataHoraFimExperiência` AS `DataHoraFimExperiência`, `experiência`.`SnoozeTime` AS `SnoozeTime`, `experiência`.`RemocaoLogica` AS `RemocaoLogica` FROM `experiência` WHERE `experiência`.`DataHoraInicioExperiência` is not null AND `experiência`.`DataHoraFimExperiência` is nullnull  ;

--
-- Restrições para despejos de tabelas
--

--
-- Limitadores para a tabela `alerta`
--
ALTER TABLE `alerta`
  ADD CONSTRAINT `ExperienciaFK` FOREIGN KEY (`IDExperiência`) REFERENCES `experiência` (`IDExperiência`) ON UPDATE CASCADE;

--
-- Limitadores para a tabela `experiência`
--
ALTER TABLE `experiência`
  ADD CONSTRAINT `UtilizadoresFK` FOREIGN KEY (`Investigador`) REFERENCES `utilizador` (`IDUtilizador`) ON UPDATE CASCADE;

--
-- Limitadores para a tabela `mediçõespassagens`
--
ALTER TABLE `mediçõespassagens`
  ADD CONSTRAINT `ExpPassagem` FOREIGN KEY (`IDExperiência`) REFERENCES `experiência` (`IDExperiência`) ON UPDATE CASCADE;

--
-- Limitadores para a tabela `mediçõessalas`
--
ALTER TABLE `mediçõessalas`
  ADD CONSTRAINT `ExpSalaFK` FOREIGN KEY (`IDExperiência`) REFERENCES `experiência` (`IDExperiência`) ON UPDATE CASCADE;

--
-- Limitadores para a tabela `mediçõestemperatura`
--
ALTER TABLE `mediçõestemperatura`
  ADD CONSTRAINT `ExpTemperatura` FOREIGN KEY (`IDExperiência`) REFERENCES `experiência` (`IDExperiência`) ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
