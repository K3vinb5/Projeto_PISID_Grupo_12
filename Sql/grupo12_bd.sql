-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Apr 22, 2024 at 01:18 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `grupo12_bd`
--
CREATE DATABASE IF NOT EXISTS `grupo12_bd` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
USE `grupo12_bd`;

DELIMITER $$
--
-- Procedures
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
CREATE DEFINER=`root`@`localhost` PROCEDURE `EditarExperiencia` (IN `descricao` TEXT, IN `numeroRatos` INT, IN `limiteRatosSala` INT, IN `segSemMovimento` INT, IN `temperaturaMinima` DECIMAL(4,2), IN `temperaturaMaxima` DECIMAL(4,2), IN `temperaturaAvisoMaximo` DECIMAL(4,2), IN `temperaturaAvisoMinimo` DECIMAL(4.2), IN `idExperiencia` INT)   BEGIN

    DECLARE inicioExp DATETIME;

    IF NOT EXISTS (SELECT * FROM experiencia WHERE IDExperiência = idExperiencia) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Está a tentar editar uma experiencia que não existe!';
    END IF;

    SELECT DataHoraInicioExperiência INTO inicioExp FROM experiencia WHERE IDExperiência = idExperiencia;
    
    IF inicioExp IS NOT NULL THEN
        UPDATE experiência e
        SET e.Descrição = IFNULL(descricao, e.Descrição)
        WHERE e.IDExperiência = idExperiencia;
    ELSE
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

DROP PROCEDURE IF EXISTS `InserirExperiencia`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `InserirExperiencia` (IN `descricao` TEXT, IN `numeroRatos` INT, IN `limiteRatosSala` INT, IN `segSemMovimento` INT, IN `temperaturaMinima` DECIMAL(4,2), IN `temperaturaMaxima` DECIMAL(4,2), IN `temperaturaAvisoMaximo` DECIMAL(4,2), IN `temperaturaAvisoMinimo` DECIMAL(4.2))   BEGIN

    DECLARE utilizador VARCHAR(200); 
    SELECT SUBSTRING_INDEX(user(), '@', 2) INTO utilizador;
    
    IF NOT EXISTS (SELECT Email FROM utilizador WHERE Email = utilizador) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ocorreu um erro ao criar a experiência!';
    END IF;
    
    INSERT INTO experiencia (Descrição, DataHoraCriaçãoExperiência, NúmeroRatos, LimiteRatosSala, SegundosSemMovimento, TemperaturaMinima, TemperaturaMaxima, TemperaturaAvisoMaximo, TemperaturaAvisoMinimo, Investigador)
    VALUES (descricao, NOW(), numeroRatos, limiteRatosSala, segSemMovimento, temperaturaMinima, temperaturaMaxima, temperaturaAvisoMaximo, temperaturaAvisoMinimo, utilizador);
    
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
CREATE DEFINER=`root`@`localhost` PROCEDURE `InserirUtilizador` (IN `email` VARCHAR(200), IN `nome` VARCHAR(100), IN `tipoUtilizador` ENUM('Investigador','AdministradorAplicacao','WriteMySql'), IN `telefone` VARCHAR(12))   BEGIN

    DECLARE email_pattern VARCHAR(255);
    DECLARE phone_pattern VARCHAR(255);
    DECLARE user_count INT;
        
    SET email_pattern = '^[A-Za-z0-9.%+-]+@[A-Za-z0-9.-]+.[A-Za-z]{2,}$';
    SET phone_pattern = '^9[1236][0-9]{7}$';

    IF email NOT RLIKE email_pattern THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email inválido!';
    END IF;
    
    IF telefone NOT RLIKE phone_pattern THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Telefone inválido!';
    END IF;
    
    SELECT COUNT(*) INTO user_count FROM utilizador WHERE Email = email;
    
    IF user_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Utilizador já existe!';
    END IF;
    
    SET @sql = CONCAT('CREATE USER ', QUOTE(email), '@', QUOTE('localhost'), ' IDENTIFIED BY ', QUOTE('Pass123!'));
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
    SET @sql = CONCAT('GRANT ', tipoUtilizador, ' TO ', QUOTE(email), '@', QUOTE('localhost'));
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
    SET @sql = CONCAT('SET DEFAULT ROLE ', tipoUtilizador, ' FOR ', QUOTE(email), '@', QUOTE('localhost'));
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    INSERT INTO utilizador (Nome, Telefone, Email)
    VALUES (nome, telefone, email);
    
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
-- Table structure for table `alerta`
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
-- Table structure for table `experiencia`
--

DROP TABLE IF EXISTS `experiencia`;
CREATE TABLE IF NOT EXISTS `experiencia` (
  `IDExperiência` int(11) NOT NULL AUTO_INCREMENT,
  `Descrição` text DEFAULT NULL,
  `DataHoraCriaçãoExperiência` datetime NOT NULL DEFAULT current_timestamp(),
  `NúmeroRatos` int(11) NOT NULL,
  `LimiteRatosSala` int(11) NOT NULL,
  `SegundosSemMovimento` int(11) NOT NULL,
  `TemperaturaMinima` decimal(4,2) NOT NULL,
  `TemperaturaMaxima` decimal(4,2) NOT NULL,
  `TemperaturaAvisoMaximo` decimal(4,2) NOT NULL,
  `TemperaturaAvisoMinimo` decimal(4,2) NOT NULL,
  `DataHoraInicioExperiência` datetime DEFAULT NULL,
  `DataHoraFimExperiência` datetime DEFAULT NULL,
  `RemocaoLogica` tinyint(1) NOT NULL DEFAULT 0,
  `Investigador` varchar(200) NOT NULL,
  PRIMARY KEY (`IDExperiência`),
  KEY `experiência_ibfk_1` (`Investigador`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Triggers `experiencia`
--
DROP TRIGGER IF EXISTS `ExperienciaInsertAfter`;
DELIMITER $$
CREATE TRIGGER `ExperienciaInsertAfter` AFTER INSERT ON `experiencia` FOR EACH ROW BEGIN

	DECLARE counter INT;
    SET counter = 1;
	CALL IniciarSala(new.IDExperiência , new.NúmeroRatos, counter);
    WHILE counter <= 10 DO
    	CALL IniciarSala(new.IDExperiência, 0, counter);
        SET counter = counter + 1;
	END WHILE;

END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `ExperienciaInsertBefore`;
DELIMITER $$
CREATE TRIGGER `ExperienciaInsertBefore` BEFORE INSERT ON `experiencia` FOR EACH ROW BEGIN

	DECLARE utilizador VARCHAR(200); 
    SELECT SUBSTRING_INDEX(user(), '@', 2) INTO utilizador;
	IF NOT new.Investigador = utilizador THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Está a tentar inserir uma experiência por outro utilizador!';
    END IF;
    
    IF NOT new.NúmeroRatos > 0 OR new.NúmeroRatos IS NULL THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'O número de ratos não pode ser menor ou igual a 0!';
    END IF;

	IF NOT new.LimiteRatosSala > 0 OR new.LimiteRatosSala IS NULL THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'O limite de ratos por sala não pode ser menor ou igual a 0!';
    END IF;    
    
    IF NOT new.SegundosSemMovimento > 0 OR new.SegundosSemMovimento IS NULL THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'O número de segundos sem movimentos não pode ser menor ou igual a 0!';
    END IF;
    
    IF new.TemperaturaMaxima IS NULL THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'O campo TemperaturaMaxima é obrigatorio!';
    END IF;
    
    IF new.TemperaturaMinima IS NULL THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'O campo TemperaturaMinima é obrigatorio!';
    END IF;
    
    IF new.TemperaturaAvisoMaximo IS NULL THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'O campo TemperaturaAvisoMaximo é obrigatorio!';
    END IF;
    
    IF new.TemperaturaAvisoMinimo IS NULL THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'O campo TemperaturaAvisoMinimo é obrigatorio!';
    END IF;
    
    IF NOT new.TemperaturaMaxima > new.TemperaturaMinima THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A temperatura minima não pode ser superior à temperatura máxima!';
    END IF;
    
    IF NOT new.TemperaturaAvisoMaximo > new.TemperaturaAvisoMinimo THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A temperatura de aviso minimo não pode ser superior à temperatura de aviso máximo!';
    END IF;
    
    IF new.DataHoraInicioExperiência IS NOT NULL THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Só pode iniciar uma experiência depois de estar criada!';
    END IF;
    
    IF new.DataHoraFimExperiência IS NOT NULL THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Não pode terminar uma experiência que ainda não começou!';
    END IF;
    
    IF new.RemocaoLogica THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Não é possivel fazer uma remoção lógica de uma experiência, antes dessa estar criada!';
    END IF;
    
    SET new.DataHoraCriaçãoExperiência = NOW();
    
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `ExperienciaUpdateBefore`;
DELIMITER $$
CREATE TRIGGER `ExperienciaUpdateBefore` BEFORE UPDATE ON `experiencia` FOR EACH ROW BEGIN

	DECLARE utilizador VARCHAR(200); 
    SELECT SUBSTRING_INDEX(user(), '@', 2) INTO utilizador;
	IF NOT new.Investigador = utilizador THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Está a tentar editar uma experiência de outro utilizador!';
    END IF;    
    
    IF old.DataHoraInicioExperiência IS NOT NULL THEN
    	IF old.DataHoraInicioExperiência <> new.DataHoraInicioExperiência THEN
        	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Não pode alterar a data/hora de inicio de uma experiencia que está ou já tenha decorrido!';
        END IF;
        
        IF old.DataHoraFimExperiência IS NOT NULL THEN
        	IF old.DataHoraFimExperiência <> new.DataHoraFimExperiência THEN
            	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Não pode alterar a data/hora de fim de uma experiencia que já tenha decorrido!';
            END IF;
        ELSE
        	IF old.RemocaoLogica <> new.RemocaoLogica THEN
            	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Não é possivel alterar o estado da experiencia!';
            END IF;
        END IF;
        
        IF new.DataHoraFimExperiência > old.DataHoraInicioExperiência THEN
        	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'O data/hora de fim da experiência não podem ser maiores que a data/hora de inicio!';
        END IF;
    
    	IF new.NúmeroRatos <> old.NúmeroRatos THEN
        	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Já não é possivel atualizar o numero de ratos!';
        END IF;
        
        IF new.LimiteRatosSala <> old.LimiteRatosSala THEN
        	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Já não é possivel atualizar o numero de ratos!';
        END IF;
        
        IF new.SegundosSemMovimento <> old.SegundosSemMovimento THEN
        	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Já não é possivel atualizar o numero de ratos!';
        END IF;
        
        IF new.TemperaturaMaxima <> old.TemperaturaMaxima THEN
        	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Já não é possivel atualizar o numero de ratos!';
        END IF;
        
        IF new.TemperaturaMinima <> old.TemperaturaMinima THEN
        	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Já não é possivel atualizar o numero de ratos!';
        END IF;
        
        IF new.TemperaturaAvisoMaximo <> old.TemperaturaAvisoMaximo THEN
        	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Já não é possivel atualizar o numero de ratos!';
        END IF;
        
        IF new.TemperaturaAvisoMinimo <> old.TemperaturaAvisoMinimo THEN
        	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Já não é possivel atualizar o numero de ratos!';
        END IF;
    END IF;
    
    IF NOT new.NúmeroRatos > 0 THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'O número de ratos não pode ser menor ou igual a 0!';
    END IF;

	IF NOT new.LimiteRatosSala > 0 THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'O limite de ratos por sala não pode ser menor ou igual a 0!';
    END IF;    
    
    IF NOT new.SegundosSemMovimento > 0 THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'O número de segundos sem movimentos não pode ser menor ou igual a 0!';
    END IF;
    
    IF NOT new.TemperaturaMaxima > new.TemperaturaMinima THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A temperatura minima não pode ser superior à temperatura máxima!';
    END IF;
    
    IF NOT new.TemperaturaAvisoMaximo > new.TemperaturaAvisoMinimo THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A temperatura de aviso minimo não pode ser superior à temperatura de aviso máximo!';
    END IF;
    
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `medicoesnaoconformes`
--

DROP TABLE IF EXISTS `medicoesnaoconformes`;
CREATE TABLE IF NOT EXISTS `medicoesnaoconformes` (
  `IDMedicao` int(11) NOT NULL AUTO_INCREMENT,
  `IDExperiencia` int(11) DEFAULT NULL,
  `RegistoRecebido` varchar(250) NOT NULL,
  `TipoMedicao` enum('Temperatura','Movimento') NOT NULL,
  `TipoDado` enum('Outlier','Dado Errado') NOT NULL,
  PRIMARY KEY (`IDMedicao`),
  KEY `medicoesnaoconformes_ibfk_1` (`IDExperiencia`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `medicoespassagem`
--

DROP TABLE IF EXISTS `medicoespassagem`;
CREATE TABLE IF NOT EXISTS `medicoespassagem` (
  `IDMedição` int(11) NOT NULL AUTO_INCREMENT,
  `DataHora` datetime NOT NULL,
  `SalaOrigem` int(11) NOT NULL,
  `SalaDestino` int(11) NOT NULL,
  `IDExperiência` int(11) DEFAULT NULL,
  `IDMongo` varchar(50) NOT NULL,
  PRIMARY KEY (`IDMedição`),
  UNIQUE KEY `IDMongo` (`IDMongo`),
  KEY `ExpPassagem` (`IDExperiência`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `medicoessala`
--

DROP TABLE IF EXISTS `medicoessala`;
CREATE TABLE IF NOT EXISTS `medicoessala` (
  `IDMedição` int(11) NOT NULL AUTO_INCREMENT,
  `IDExperiência` int(11) DEFAULT NULL,
  `NúmeroRatosFinal` int(11) NOT NULL,
  `Sala` int(11) NOT NULL,
  PRIMARY KEY (`IDMedição`),
  KEY `ExpSalaFK` (`IDExperiência`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `medicoestemperatura`
--

DROP TABLE IF EXISTS `medicoestemperatura`;
CREATE TABLE IF NOT EXISTS `medicoestemperatura` (
  `IDMedição` int(11) NOT NULL AUTO_INCREMENT,
  `DataHora` datetime NOT NULL,
  `Leitura` decimal(4,2) NOT NULL,
  `Sensor` int(11) NOT NULL,
  `IDExperiência` int(11) DEFAULT NULL,
  PRIMARY KEY (`IDMedição`),
  KEY `ExpTemperatura` (`IDExperiência`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `parametroadicional`
--

DROP TABLE IF EXISTS `parametroadicional`;
CREATE TABLE IF NOT EXISTS `parametroadicional` (
  `IDParâmetro` int(11) NOT NULL AUTO_INCREMENT,
  `EmailUtilizador` varchar(200) NOT NULL,
  `NrRegistosOutlierTemperatura` int(11) NOT NULL DEFAULT 25,
  `NrRegistosAlertaTemperatura` int(11) NOT NULL DEFAULT 15,
  `ControloSpamTemperatura` int(11) NOT NULL DEFAULT 30,
  `ControloSpamMovimentos` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`IDParâmetro`),
  KEY `EmailUtilizador` (`EmailUtilizador`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `utilizador`
--

DROP TABLE IF EXISTS `utilizador`;
CREATE TABLE IF NOT EXISTS `utilizador` (
  `Email` varchar(200) NOT NULL,
  `Nome` varchar(100) NOT NULL,
  `Telefone` varchar(12) NOT NULL,
  `RemocaoLogica` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`Email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_expadecorrer`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `v_expadecorrer`;
CREATE TABLE IF NOT EXISTS `v_expadecorrer` (
`IDExperiência` int(11)
,`Descrição` text
,`Investigador` varchar(200)
,`DataHoraCriaçãoExperiência` datetime
,`NúmeroRatos` int(11)
,`LimiteRatosSala` int(11)
,`SegundosSemMovimento` int(11)
,`TemperaturaMinima` decimal(4,2)
,`TemperaturaMaxima` decimal(4,2)
,`DataHoraInicioExperiência` datetime
,`DataHoraFimExperiência` datetime
,`RemocaoLogica` tinyint(1)
);

-- --------------------------------------------------------

--
-- Structure for view `v_expadecorrer`
--
DROP TABLE IF EXISTS `v_expadecorrer`;

DROP VIEW IF EXISTS `v_expadecorrer`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_expadecorrer`  AS SELECT `e`.`IDExperiência` AS `IDExperiência`, `e`.`Descrição` AS `Descrição`, `e`.`Investigador` AS `Investigador`, `e`.`DataHoraCriaçãoExperiência` AS `DataHoraCriaçãoExperiência`, `e`.`NúmeroRatos` AS `NúmeroRatos`, `e`.`LimiteRatosSala` AS `LimiteRatosSala`, `e`.`SegundosSemMovimento` AS `SegundosSemMovimento`, `e`.`TemperaturaMinima` AS `TemperaturaMinima`, `e`.`TemperaturaMaxima` AS `TemperaturaMaxima`, `e`.`DataHoraInicioExperiência` AS `DataHoraInicioExperiência`, `e`.`DataHoraFimExperiência` AS `DataHoraFimExperiência`, `e`.`RemocaoLogica` AS `RemocaoLogica` FROM `experiencia` AS `e` WHERE `e`.`DataHoraInicioExperiência` is not null AND `e`.`DataHoraFimExperiência` is null ;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `alerta`
--
ALTER TABLE `alerta`
  ADD CONSTRAINT `ExperienciaFK` FOREIGN KEY (`IDExperiência`) REFERENCES `experiencia` (`IDExperiência`) ON UPDATE CASCADE;

--
-- Constraints for table `experiencia`
--
ALTER TABLE `experiencia`
  ADD CONSTRAINT `experiencia_ibfk_1` FOREIGN KEY (`Investigador`) REFERENCES `utilizador` (`Email`) ON UPDATE CASCADE;

--
-- Constraints for table `medicoesnaoconformes`
--
ALTER TABLE `medicoesnaoconformes`
  ADD CONSTRAINT `medicoesnaoconformes_ibfk_1` FOREIGN KEY (`IDExperiencia`) REFERENCES `experiencia` (`IDExperiência`) ON UPDATE CASCADE;

--
-- Constraints for table `medicoespassagem`
--
ALTER TABLE `medicoespassagem`
  ADD CONSTRAINT `medicoespassagem_ibfk_1` FOREIGN KEY (`IDExperiência`) REFERENCES `experiencia` (`IDExperiência`) ON UPDATE CASCADE;

--
-- Constraints for table `medicoessala`
--
ALTER TABLE `medicoessala`
  ADD CONSTRAINT `medicoessala_ibfk_1` FOREIGN KEY (`IDExperiência`) REFERENCES `experiencia` (`IDExperiência`) ON UPDATE CASCADE;

--
-- Constraints for table `medicoestemperatura`
--
ALTER TABLE `medicoestemperatura`
  ADD CONSTRAINT `medicoestemperatura_ibfk_1` FOREIGN KEY (`IDExperiência`) REFERENCES `experiencia` (`IDExperiência`) ON UPDATE CASCADE;

--
-- Constraints for table `parametroadicional`
--
ALTER TABLE `parametroadicional`
  ADD CONSTRAINT `parametroadicional_ibfk_1` FOREIGN KEY (`EmailUtilizador`) REFERENCES `utilizador` (`Email`) ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
