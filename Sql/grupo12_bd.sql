-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 13, 2024 at 11:24 PM
-- Server version: 10.4.27-MariaDB
-- PHP Version: 8.1.12

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

	DELETE FROM experiencia
	WHERE IDExperiencia = idExperiencia;

END$$

DROP PROCEDURE IF EXISTS `ApagarUtilizador`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ApagarUtilizador` (IN `email` VARCHAR(50))   BEGIN

	UPDATE utilizador u
    SET u.RemocaoLogica = TRUE
    WHERE u.EmailUtilizador = email;
    
END$$

DROP PROCEDURE IF EXISTS `AtribuirExperienciaInvestigador`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `AtribuirExperienciaInvestigador` (IN `idExperiencia` INT, IN `emailInvestigador` VARCHAR(200))   BEGIN

	UPDATE experiencia e
    SET e.Investigador = IFNULL(emailInvestigador, e.Investigador)
    WHERE e.IDExperiencia = idExperiencia;
    
END$$

DROP PROCEDURE IF EXISTS `AtualizarNumRatosSala`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `AtualizarNumRatosSala` (IN `salaOrigem` INT, IN `salaDestino` INT, IN `idExperiencia` INT)   BEGIN

	DECLARE valorOrigem, valorDestino INT;
    SELECT m.NúmeroRatosFinal INTO valorOrigem FROM medicoessala m WHERE m.IDExperiencia = idExperiencia AND m.Sala = salaOrigem LIMIT 1;
    SELECT m.NúmeroRatosFinal INTO valorDestino FROM medicoessala m WHERE m.IDExperiencia = idExperiencia AND m.Sala = salaDestino LIMIT 1;
    
	IF valorOrigem > 0 THEN
		UPDATE medicoessala
		SET NúmeroRatosFinal = (valorOrigem - 1)
		WHERE Sala = salaOrigem AND IDExperiencia = idExperiencia;
		
		UPDATE medicoessala
		SET NúmeroRatosFinal = (valorDestino + 1)
		WHERE Sala = salaDestino AND IDExperiencia = idExperiencia;
	END IF;

END$$

DROP PROCEDURE IF EXISTS `ComecarTerminarExperienca`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ComecarTerminarExperienca` (IN `idExperienciaPretendida` INT)   BEGIN

	DECLARE idExperiencia INT;
    CALL ObterExperienciaADecorrer(idExperiencia);
    
    IF idExperiencia IS NULL THEN
    	UPDATE experiencia e
        SET e.DataHoraInicioExperiência = NOW()
        WHERE e.IDExperiencia = idExperienciaPretendida;
	ELSE
    	IF idExperienciaPretendida = idExperiencia THEN
        	UPDATE experiencia e
            SET e.DataHoraFimExperiência = NOW()
            WHERE e.IDExperiencia = idExperienciaPretendida;
		END IF;
	END IF;
    
END$$

DROP PROCEDURE IF EXISTS `DesativarSensor`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `DesativarSensor` (IN `idSensor` INT)   BEGIN

	UPDATE sensor s
    SET s.IsActive = FALSE
	WHERE s.IDSensor = idSensor;

END$$

DROP PROCEDURE IF EXISTS `EditarExperiencia`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `EditarExperiencia` (IN `descricao` TEXT, IN `numeroRatos` INT, IN `limiteRatosSala` INT, IN `segSemMovimento` INT, IN `temperaturaMinima` DECIMAL(4,2), IN `temperaturaMaxima` DECIMAL(4,2), IN `temperaturaAvisoMaximo` DECIMAL(4,2), IN `temperaturaAvisoMinimo` DECIMAL(4.2), IN `idExperiencia` INT)   BEGIN
    SET @sql = 'SELECT COUNT(*) INTO @expExists FROM experiencia WHERE IDExperiencia = ?';
    PREPARE stmt FROM @sql;
    EXECUTE stmt USING idExperiencia;
    DEALLOCATE PREPARE stmt;
    
    IF @expExists <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Está a tentar editar uma experiencia que não existe!';
    END IF;

    SET @sql = 'SELECT DataHoraInicioExperiência INTO @inicioExp FROM experiencia WHERE IDExperiencia = ?';
    PREPARE stmt FROM @sql;
    EXECUTE stmt USING idExperiencia;
    DEALLOCATE PREPARE stmt;
    
    IF @inicioExp IS NOT NULL THEN
        UPDATE experiencia e
        SET e.Descrição = IFNULL(descricao, e.Descrição)
        WHERE e.IDExperiencia = idExperiencia;
    ELSE
        UPDATE experiencia e
        SET e.Descrição = IFNULL(descricao, e.Descrição), 
            e.NúmeroRatos = IFNULL(numeroRatos, e.NúmeroRatos), 
            e.LimiteRatosSala = IFNULL(limiteRatosSala, e.LimiteRatosSala), 
            e.SegundosSemMovimento = IFNULL(segSemMovimento, e.SegundosSemMovimento), 
            e.TemperaturaMinima = IFNULL(temperaturaMinima, e.TemperaturaMinima), 
            e.TemperaturaMaxima = IFNULL(temperaturaMaxima, e.TemperaturaMaxima), 
            e.TemperaturaAvisoMaximo = IFNULL(temperaturaAvisoMaximo, e.TemperaturaAvisoMaximo), 
            e.TemperaturaAvisoMinimo = IFNULL(temperaturaAvisoMinimo, e.TemperaturaAvisoMinimo)
        WHERE e.IDExperiencia = idExperiencia;
    END IF;
END$$

DROP PROCEDURE IF EXISTS `EditarNumRatosSala`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `EditarNumRatosSala` (IN `idExperiencia` INT, IN `numeroRatos` INT, IN `sala` INT)   BEGIN

	UPDATE medicoessala m
    SET m.NúmeroRatosFinal = IFNULL(numeroRatos, m.NúmeroRatosFinal)
    WHERE m.IDExperiencia = idExperiencia AND m.Sala = sala;

END$$

DROP PROCEDURE IF EXISTS `EditarParametrosAdicionais`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `EditarParametrosAdicionais` (IN `nrRegistosOutlierTemperatura` INT, IN `nrRegistosAlertaTemperatura` INT, IN `controloSpamTemperatura` INT, IN `controloSpamMovimentos` INT)   BEGIN

	UPDATE parametroadicional p
	SET p.NrRegistosOutlierTemperatura = IFNULL(nrRegistosOutlierTemperatura, e.NrRegistosOutlierTemperatura), 
    	p.NrRegistosAlertaTemperatura = IFNULL(nrRegistosAlertaTemperatura, e.NrRegistosAlertaTemperatura), 
        p.ControloSpamTemperatura = IFNULL(controloSpamTemperatura, e.ControloSpamTemperatura),
        p.ControloSpamMovimentos = IFNULL(controloSpamMovimentos, e.ControloSpamMovimentos);

END$$

DROP PROCEDURE IF EXISTS `EditarSensor`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `EditarSensor` (IN `idSensor` INT, IN `nome` VARCHAR(50), IN `idTipoSensor` INT)   BEGIN

	UPDATE sensor s
    SET s.Nome = IFNULL(nome, s.Nome),
    	s.IDTipoSensor = IFNULL(idTipoSensor, s.IDTipoSensor)
	WHERE s.IDSensor = idSensor;

END$$

DROP PROCEDURE IF EXISTS `EditarTipoSensor`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `EditarTipoSensor` (IN `idTipoSensor` INT, IN `designacao` VARCHAR(50))   BEGIN

	UPDATE tiposensor t
    SET t.Designacao = IFNULL(designacao, t.Designacao)
	WHERE t.IDTipoSensor = idTipoSensor;

END$$

DROP PROCEDURE IF EXISTS `EditarUtilizador`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `EditarUtilizador` (IN `emailUtilizador` VARCHAR(200), IN `novoEmailUtilizador` VARCHAR(200), IN `novoNomeUtilizador` VARCHAR(100), IN `novoTipoUtilizador` ENUM('Investigador','AdministradorAplicacao','WriteMySql'), IN `novoTelefoneUtilizador` VARCHAR(12), IN `novaPassword` VARCHAR(100))   BEGIN

	DECLARE email_pattern VARCHAR(255);
    DECLARE phone_pattern VARCHAR(255);
    DECLARE user_exists INT;
    DECLARE novo_email_exists INT;
    DECLARE utilizadorLogado VARCHAR(200);
    DECLARE actual_role VARCHAR(100);
        
    SET email_pattern = '^[A-Za-z0-9.%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';
    SET phone_pattern = '^9[1236][0-9]{7}$';
    SELECT COUNT(*) INTO user_exists FROM utilizador WHERE Email = emailUtilizador;
    SELECT COUNT(*) INTO novo_email_exists FROM utilizador WHERE Email = novo_email_exists;
    SELECT SUBSTRING_INDEX(user(), '@', 2) INTO utilizadorLogado;
    
    IF novoEmailUtilizador IS NOT NULL AND novoEmailUtilizador NOT RLIKE email_pattern THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email inválido!';
    END IF;
    
    IF novoEmailUtilizador IS NOT NULL AND novo_email_exists > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'O novo email já é usado por outro utilizador!';
    END IF;
    
    IF novoTelefoneUtilizador IS NOT NULL AND novoTelefoneUtilizador NOT RLIKE phone_pattern THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Telefone inválido!';
    END IF;
    
    IF novoTipoUtilizador IS NOT NULL AND NOT (novoTipoUtilizador LIKE 'Investigador' OR novoTipoUtilizador LIKE 'AdministradorAplicacao' OR novoTipoUtilizador LIKE 'WriteMySql') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tipo de utilizador inválido!';
    END IF;
    
    IF emailUtilizador IS NOT NULL THEN
    	IF user_exists <= 0 THEN
        	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Está a tentar atualizar um utilizador que não existe!';
        END IF;
        IF NOT emailUtilizador = utilizadorLogado THEN
            IF NOT EXISTS (SELECT * FROM mysql.roles_mapping WHERE User = utilizadorLogado AND Host = 'localhost' AND Role = 'AdministradorAplicacao') THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Não pode editar informações de outro utilizador!';
            END IF;
        END IF;
        
        UPDATE utilizador u
        SET u.Email = IFNULL(novoEmailUtilizador, u.Email), 
            u.Nome = IFNULL(novoNomeUtilizador, u.Nome), 
            u.Telefone = IFNULL(novoTelefoneUtilizador, u.Telefone)
        WHERE u.Email = emailUtilizador;
        
        IF novoTipoUtilizador IS NOT NULL THEN
        	SELECT Role INTO actual_role FROM mysql.roles_mapping WHERE User = emailUtilizador AND Host = 'localhost' AND Role = 'AdministradorAplicacao';
        	IF NOT actual_role = novoTipoUtilizador THEN
            	SET @sql = CONCAT('REVOKE ', QUOTE(actual_role), ' FROM ', QUOTE(emailUtilizador), '@', QUOTE('localhost'));
                PREPARE stmt FROM @sql;
                EXECUTE stmt;
                DEALLOCATE PREPARE stmt;
                
                SET @sql = CONCAT('GRANT ', novoTipoUtilizador, ' TO ', QUOTE(emailUtilizador), '@', QUOTE('localhost'));
                PREPARE stmt FROM @sql;
                EXECUTE stmt;
                DEALLOCATE PREPARE stmt;

                SET @sql = CONCAT('SET DEFAULT ROLE ', novoTipoUtilizador, ' FOR ', QUOTE(emailUtilizador), '@', QUOTE('localhost'));
                PREPARE stmt FROM @sql;
                EXECUTE stmt;
                DEALLOCATE PREPARE stmt;
            END IF;
        END IF;
        
        IF novaPassword IS NOT NULL THEN
        	SET @sql = CONCAT('ALTER USER ', QUOTE(emailUtilizador), '@', QUOTE('localhost'), ' IDENTIFIED BY ', QUOTE(novaPassword));
            PREPARE stmt FROM @sql;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
        END IF;
        
        IF novoEmailUtilizador IS NOT NULL AND NOT emailUtilizador = novoEmailUtilizador THEN
        	SET @sql = CONCAT('RENAME USER ', QUOTE(emailUtilizador), '@', QUOTE('localhost'), ' TO ', QUOTE(novoEmailUtilizador), '@', QUOTE('localhost'));
            PREPARE stmt FROM @sql;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
        END IF;
    ELSE
        UPDATE utilizador u
        SET u.Email = IFNULL(novoEmailUtilizador, u.Email), 
            u.Nome = IFNULL(novoNomeUtilizador, u.Nome), 
            u.Telefone = IFNULL(novoTelefoneUtilizador, u.Telefone)
        WHERE u.Email = utilizadorLogado;
        
        IF novoTipoUtilizador IS NOT NULL THEN
        	SELECT Role INTO actual_role FROM mysql.roles_mapping WHERE User = utilizadorLogado AND Host = 'localhost' AND Role = 'AdministradorAplicacao';
        	IF NOT actual_role = novoTipoUtilizador THEN
            	SET @sql = CONCAT('REVOKE ', QUOTE(actual_role), ' FROM ', QUOTE(utilizadorLogado), '@', QUOTE('localhost'));
                PREPARE stmt FROM @sql;
                EXECUTE stmt;
                DEALLOCATE PREPARE stmt;
                
                SET @sql = CONCAT('GRANT ', novoTipoUtilizador, ' TO ', QUOTE(utilizadorLogado), '@', QUOTE('localhost'));
                PREPARE stmt FROM @sql;
                EXECUTE stmt;
                DEALLOCATE PREPARE stmt;

                SET @sql = CONCAT('SET DEFAULT ROLE ', novoTipoUtilizador, ' FOR ', QUOTE(utilizadorLogado), '@', QUOTE('localhost'));
                PREPARE stmt FROM @sql;
                EXECUTE stmt;
                DEALLOCATE PREPARE stmt;
            END IF;
        END IF;
        
        IF novaPassword IS NOT NULL THEN
        	SET @sql = CONCAT('ALTER USER ', QUOTE(utilizadorLogado), '@', QUOTE('localhost'), ' IDENTIFIED BY ', QUOTE(novaPassword));
            PREPARE stmt FROM @sql;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
        END IF;
        
        IF novoEmailUtilizador IS NOT NULL AND NOT utilizadorLogado = novoEmailUtilizador THEN
        	SET @sql = CONCAT('RENAME USER ', QUOTE(utilizadorLogado), '@', QUOTE('localhost'), ' TO ', QUOTE(novoEmailUtilizador), '@', QUOTE('localhost'));
            PREPARE stmt FROM @sql;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
        END IF;
    END IF;

END$$

DROP PROCEDURE IF EXISTS `IniciarSala`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `IniciarSala` (IN `idExperiencia` INT, IN `numeroRatos` INT, IN `sala` INT)   BEGIN

	INSERT INTO medicoessala (IDExperiencia, NúmeroRatosFinal, Sala)
	VALUES (idExperiencia, numeroRatos, sala);

END$$

DROP PROCEDURE IF EXISTS `InserirAlerta`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `InserirAlerta` (IN `sala` INT, IN `sensor` INT, IN `leitura` DECIMAL(4,2), IN `tipoAlerta` VARCHAR(100), IN `mensagem` VARCHAR(100))   BEGIN

	IF sala IS NOT NULL THEN
    	INSERT INTO alerta (DataHora, Sala, TipoAlerta, Mensagem) 
        VALUES (NOW(), sala, tipoAlerta, mensagem);
    ELSEIF sensor IS NOT NULL AND leitura IS NOT NULL THEN
    	INSERT INTO alerta (DataHora, IDSensor, Leitura, TipoAlerta, Mensagem) 
        VALUES (NOW(), sensor, leitura, tipoAlerta, mensagem);
	END IF;

END$$

DROP PROCEDURE IF EXISTS `InserirExperiencia`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `InserirExperiencia` (IN `descricao` TEXT, IN `numeroRatos` INT, IN `limiteRatosSala` INT, IN `segSemMovimento` INT, IN `temperaturaMinima` DECIMAL(4,2), IN `temperaturaMaxima` DECIMAL(4,2), IN `temperaturaAvisoMaximo` DECIMAL(4,2), IN `temperaturaAvisoMinimo` DECIMAL(4.2), IN `emailInvestigador` VARCHAR(200))   BEGIN

    DECLARE utilizador VARCHAR(200); 
    SELECT SUBSTRING_INDEX(user(), '@', 2) INTO utilizador;
    
    IF NOT EXISTS (SELECT Email FROM utilizador WHERE Email = utilizador) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ocorreu um erro ao criar a experiência!';
    END IF;
    
    IF NOT (emailInvestigador IS NULL OR emailInvestigador = '') THEN
    	INSERT INTO experiencia (Descrição, DataHoraCriaçãoExperiência, NúmeroRatos, LimiteRatosSala, SegundosSemMovimento, TemperaturaMinima, TemperaturaMaxima, TemperaturaAvisoMaximo, TemperaturaAvisoMinimo, Investigador)
    	VALUES (descricao, NOW(), numeroRatos, limiteRatosSala, segSemMovimento, temperaturaMinima, temperaturaMaxima, temperaturaAvisoMaximo, temperaturaAvisoMinimo, emailInvestigador);
    ELSE
    	INSERT INTO experiencia (Descrição, DataHoraCriaçãoExperiência, NúmeroRatos, LimiteRatosSala, SegundosSemMovimento, TemperaturaMinima, TemperaturaMaxima, TemperaturaAvisoMaximo, TemperaturaAvisoMinimo, Investigador)
    	VALUES (descricao, NOW(), numeroRatos, limiteRatosSala, segSemMovimento, temperaturaMinima, temperaturaMaxima, temperaturaAvisoMaximo, temperaturaAvisoMinimo, utilizador);
    END IF;

END$$

DROP PROCEDURE IF EXISTS `InserirMovimento`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `InserirMovimento` (IN `Hora` DATETIME, IN `SalaOrigem` INT, IN `SalaDestino` INT)   BEGIN

    INSERT INTO medicoespassagem (DataHora, SalaOrigem, SalaDestino)
    VALUES (Hora, SalaOrigem, SalaDestino);

END$$

DROP PROCEDURE IF EXISTS `InserirNaoConformes`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `InserirNaoConformes` (IN `registoRecebido` VARCHAR(255), IN `TipoMedicao` ENUM('Temperatura','Movimento'), IN `tipoDado` ENUM('Outlier','Dado Errado'))   BEGIN

	INSERT INTO medicoesnaoconformes (RegistoRecebido, TipoMedicao, TipoDado)
    VALUES (registoRecebido, TipoMedicao, tipoDado);

END$$

DROP PROCEDURE IF EXISTS `InserirSensor`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `InserirSensor` (IN `nome` VARCHAR(50), IN `idTipoSensor` INT)   BEGIN

	INSERT INTO sensor (None, IDTipoSensor)
    VALUES (nome, idTipoSensor);
    
END$$

DROP PROCEDURE IF EXISTS `InserirTemperatura`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `InserirTemperatura` (IN `Hora` DATETIME, IN `Leitura` DECIMAL(4,2), IN `Sensor` INT)   BEGIN

    INSERT INTO medicoestemperatura (DataHora, Leitura, Sensor)
    VALUES (Hora, Leitura, Sensor);

END$$

DROP PROCEDURE IF EXISTS `InserirTipoSensor`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `InserirTipoSensor` (IN `designacao` VARCHAR(50))   BEGIN

	INSERT INTO tiposensor (Designacao) 
    VALUES (designacao);

END$$

DROP PROCEDURE IF EXISTS `InserirUtilizador`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `InserirUtilizador` (IN `emailUtilizador` VARCHAR(200), IN `nomeUtilizador` VARCHAR(100), IN `tipoUtilizador` ENUM('Investigador','AdministradorAplicacao','WriteMySql'), IN `telefoneUtilizador` VARCHAR(12))   BEGIN

    DECLARE email_pattern VARCHAR(255);
    DECLARE phone_pattern VARCHAR(255);
    DECLARE user_exists INT;
        
    SET email_pattern = '^[A-Za-z0-9.%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';
    SET phone_pattern = '^9[1236][0-9]{7}$';
    SELECT COUNT(*) INTO user_exists FROM utilizador WHERE Email = emailUtilizador;

    IF emailUtilizador NOT RLIKE email_pattern THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Email inválido!';
    END IF;
    
    IF telefoneUtilizador NOT RLIKE phone_pattern THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Telefone inválido!';
    END IF;
    
    IF NOT (tipoUtilizador LIKE 'Investigador' OR tipoUtilizador LIKE 'AdministradorAplicacao' OR tipoUtilizador LIKE 'WriteMySql') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tipo de utilizador inválido!';
    END IF;

    IF user_exists > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Utilizador já existe!';
    END IF;
    
    SET @sql = CONCAT('CREATE USER ', QUOTE(emailUtilizador), '@', QUOTE('localhost'), ' IDENTIFIED BY ', QUOTE('Pass123!'));
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
    SET @sql = CONCAT('GRANT ', tipoUtilizador, ' TO ', QUOTE(emailUtilizador), '@', QUOTE('localhost'));
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
    SET @sql = CONCAT('SET DEFAULT ROLE ', tipoUtilizador, ' FOR ', QUOTE(emailUtilizador), '@', QUOTE('localhost'));
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    INSERT INTO utilizador (Nome, Telefone, Email)
    VALUES (nomeUtilizador, telefoneUtilizador, emailUtilizador);
    
END$$

DROP PROCEDURE IF EXISTS `ObterExperiencia`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ObterExperiencia` (IN `idExperiencia` INT)   BEGIN

	SELECT * FROM experiencia e WHERE e.IDExperiencia = idExperiencia;
    
END$$

DROP PROCEDURE IF EXISTS `ObterExperienciaADecorrer`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ObterExperienciaADecorrer` (OUT `idExperienciaDecorrer` INT)   BEGIN

    SELECT IDExperiencia INTO idExperienciaDecorrer FROM v_expadecorrer LIMIT 1;
    
END$$

DROP PROCEDURE IF EXISTS `ObterExperienciasInvestigador`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ObterExperienciasInvestigador` (IN `email` VARCHAR(200))   BEGIN

	SELECT * FROM experiencia WHERE Investigador = email;

END$$

DROP PROCEDURE IF EXISTS `ObterInfoUtilizador`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ObterInfoUtilizador` (IN `email` VARCHAR(200))   BEGIN

	SELECT * FROM utilizador u WHERE u.Email = email;
    
END$$

DROP PROCEDURE IF EXISTS `ObterListaExperiencias`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ObterListaExperiencias` ()   BEGIN

	SELECT * FROM experiencia;

END$$

DROP PROCEDURE IF EXISTS `ObterListaSensores`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ObterListaSensores` ()   BEGIN

	SELECT * FROM sensor s, tiposensor t WHERE s.IDTipoSensor=t.IDTipoSensor AND IsActive = TRUE;

END$$

DROP PROCEDURE IF EXISTS `ObterPassagensExperiencia`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ObterPassagensExperiencia` (IN `idExperiencia` INT)   BEGIN

	SELECT * FROM medicoespassagem m WHERE m.IDExperiencia = idExperiencia;
    
END$$

DROP PROCEDURE IF EXISTS `ObterRatosSalasExperiencia`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ObterRatosSalasExperiencia` (IN `idExperiencia` INT)   BEGIN

	SELECT * FROM medicoessala m WHERE m.IDExperiencia = idExperiencia ORDER BY m.Sala;
    
END$$

DROP PROCEDURE IF EXISTS `ObterRoleUtilizador`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ObterRoleUtilizador` ()   BEGIN

	DECLARE utilizador VARCHAR(200); 
    SELECT SUBSTRING_INDEX(user(), '@', 2) INTO utilizador;
	SELECT * FROM mysql.roles_mapping WHERE User = utilizador AND Host = 'localhost';
    
END$$

DROP PROCEDURE IF EXISTS `ObterTemperaturasExperiencia`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ObterTemperaturasExperiencia` (IN `idExperiencia` INT)   BEGIN

	SELECT * FROM medicoestemperatura m WHERE m.IDExperiencia = idExperiencia;
    
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
  `IDSensor` int(11) DEFAULT NULL,
  `Leitura` decimal(4,2) DEFAULT NULL,
  `TipoAlerta` enum('Sem movimento','Temperatura','Capacidade da sala','Temperatura1','Temperatura2','Temperatura3') NOT NULL,
  `Mensagem` varchar(100) NOT NULL,
  `IDExperiencia` int(11) DEFAULT NULL,
  PRIMARY KEY (`IDAlerta`),
  KEY `ExperienciaFK` (`IDExperiencia`)
) ENGINE=InnoDB AUTO_INCREMENT=43 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `alerta`
--

INSERT INTO `alerta` (`IDAlerta`, `DataHora`, `Sala`, `IDSensor`, `Leitura`, `TipoAlerta`, `Mensagem`, `IDExperiencia`) VALUES
(1, '2024-05-13 19:13:28', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 39),
(2, '2024-05-13 19:13:28', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 39),
(3, '2024-05-13 19:13:28', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 39),
(4, '2024-05-13 19:13:28', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 39),
(5, '2024-05-13 19:13:28', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 39),
(6, '2024-05-13 19:13:28', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 39),
(7, '2024-05-13 19:13:28', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 39),
(8, '2024-05-13 19:13:28', 2, NULL, NULL, 'Capacidade da sala', 'Limite de ratos atingido!', NULL),
(9, '2024-05-13 19:16:43', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 40),
(10, '2024-05-13 19:16:43', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 40),
(11, '2024-05-13 19:16:43', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 40),
(12, '2024-05-13 19:16:43', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 40),
(13, '2024-05-13 19:16:43', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 40),
(14, '2024-05-13 19:16:43', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 40),
(15, '2024-05-13 19:16:43', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 40),
(16, '2024-05-13 19:16:43', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 40),
(17, '2024-05-13 19:16:43', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 40),
(18, '2024-05-13 19:16:43', 2, NULL, NULL, 'Capacidade da sala', 'Limite de ratos atingido!', NULL),
(19, '2024-05-13 19:21:14', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 41),
(20, '2024-05-13 19:21:14', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 41),
(21, '2024-05-13 19:21:14', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 41),
(22, '2024-05-13 19:21:14', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 41),
(23, '2024-05-13 19:21:14', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 41),
(24, '2024-05-13 19:21:14', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 41),
(25, '2024-05-13 19:21:14', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 41),
(26, '2024-05-13 19:21:14', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 41),
(27, '2024-05-13 19:21:14', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 41),
(28, '2024-05-13 19:21:14', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 41),
(29, '2024-05-13 19:21:14', 2, NULL, NULL, 'Capacidade da sala', 'Limite de ratos atingido!', NULL);

--
-- Triggers `alerta`
--
DROP TRIGGER IF EXISTS `AlertaInsertBefore`;
DELIMITER $$
CREATE TRIGGER `AlertaInsertBefore` BEFORE INSERT ON `alerta` FOR EACH ROW BEGIN

	DECLARE lastAlertTime DATETIME;
	DECLARE idExperiencia INT;
    DECLARE controloSpam INT;
    
    CALL ObterExperienciaADecorrer(idExperiencia);    
    SET new.IDExperiencia = idExperiencia;
    
    IF NEW.TipoAlerta IN ('Temperatura','Temperatura1','Temperatura2','Temperatura3') THEN
    	IF NOT EXISTS (SELECT * FROM sensor WHERE IDSensor = new.IDSensor AND IsActive = TRUE) THEN
    		SET new.IDSensor = (SELECT s.IDSensor FROM sensor s, tiposensor t WHERE s.Nome = 'Not Defined' AND s.IDTipoSensor = t.IDTipoSensor);
    	END IF;        
    	SELECT ControloSpamTemperatura INTO controloSpam FROM parametroadicional LIMIT 1;
    ELSEIF NEW.TipoAlerta IN ('Capacidade da sala') THEN
    	SELECT ControloSpamMovimentos INTO controloSpam FROM parametroadicional LIMIT 1;
    END IF;
	
	-- Verificar se existe spam
    SELECT DataHora INTO lastAlertTime
    FROM alerta
    WHERE TipoAlerta = NEW.TipoAlerta
    ORDER BY DataHora DESC
    LIMIT 1;

    IF TIMESTAMPDIFF(SECOND, lastAlertTime, NEW.DataHora) < controloSpam THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Spam recusado';
    END IF;

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `experiencia`
--

DROP TABLE IF EXISTS `experiencia`;
CREATE TABLE IF NOT EXISTS `experiencia` (
  `IDExperiencia` int(11) NOT NULL AUTO_INCREMENT,
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
  `Investigador` varchar(200) NOT NULL,
  PRIMARY KEY (`IDExperiencia`),
  KEY `experiência_ibfk_1` (`Investigador`)
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `experiencia`
--

INSERT INTO `experiencia` (`IDExperiencia`, `Descrição`, `DataHoraCriaçãoExperiência`, `NúmeroRatos`, `LimiteRatosSala`, `SegundosSemMovimento`, `TemperaturaMinima`, `TemperaturaMaxima`, `TemperaturaAvisoMaximo`, `TemperaturaAvisoMinimo`, `DataHoraInicioExperiência`, `DataHoraFimExperiência`, `Investigador`) VALUES
(24, 'Nova desc', '2024-04-22 17:53:48', 44, 15, 45, '10.00', '25.00', '15.00', '11.00', '2024-05-06 00:31:13', '2024-05-06 00:35:52', 'pedro@iscte.pt'),
(25, 'teste', '2024-04-22 17:56:21', 50, 8, 30, '5.00', '20.00', '18.00', '7.00', NULL, NULL, 'pedro@iscte.pt'),
(26, 'Experiencia editada 123', '2024-04-22 21:47:49', 20, 5, 10, '19.00', '24.00', '24.00', '19.00', NULL, NULL, 'pedro@iscte.pt'),
(27, 'teste 1', '2024-04-22 22:35:13', 10, 2, 10, '15.00', '25.00', '20.00', '19.00', NULL, NULL, 'fatima@iscte.pt'),
(28, 'Experiencia com email NULL', '2024-04-22 22:35:55', 10, 2, 10, '15.00', '25.00', '20.00', '19.00', NULL, NULL, 'fatima@iscte.pt'),
(37, 'Experiencia de teste', '2024-05-05 22:48:21', 15, 2, 23, '11.00', '22.00', '21.00', '12.00', NULL, NULL, 'pedro@iscte.pt'),
(38, 'Outra experiencia', '2024-05-05 23:27:22', 33, 3, 33, '13.00', '33.00', '32.00', '14.00', NULL, NULL, 'pedro@iscte.pt'),
(39, 'Nova experiencia', '2024-05-13 19:13:07', 10, 1, 100, '0.00', '99.99', '99.00', '1.00', '2024-05-13 19:13:13', '2024-05-13 19:13:28', 'pedro@iscte.pt'),
(40, 'Outra nova experiencia', '2024-05-13 19:16:30', 100, 20, 100, '0.00', '99.99', '99.00', '1.00', '2024-05-13 19:16:36', '2024-05-13 19:16:43', 'pedro@iscte.pt'),
(41, 'Mais outra exp', '2024-05-13 19:21:05', 100, 20, 100, '0.00', '55.00', '54.00', '1.00', NULL, NULL, 'pedro@iscte.pt');

--
-- Triggers `experiencia`
--
DROP TRIGGER IF EXISTS `ExperienciaDeleteBefore`;
DELIMITER $$
CREATE TRIGGER `ExperienciaDeleteBefore` BEFORE DELETE ON `experiencia` FOR EACH ROW BEGIN

	DECLARE utilizador VARCHAR(200); 
    SELECT SUBSTRING_INDEX(user(), '@', 2) INTO utilizador;
	IF NOT old.Investigador = utilizador THEN
    	IF NOT EXISTS (SELECT * FROM mysql.roles_mapping WHERE User = utilizador AND Host = 'localhost' AND Role = 'AdministradorAplicacao') THEN
    		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Está a tentar editar uma experiência de outro utilizador!';
		END IF;
	END IF;

END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `ExperienciaInsertAfter`;
DELIMITER $$
CREATE TRIGGER `ExperienciaInsertAfter` AFTER INSERT ON `experiencia` FOR EACH ROW BEGIN

	DECLARE counter INT DEFAULT 1;
    
	CALL IniciarSala(new.IDExperiencia , new.NúmeroRatos, counter);
    SELECT counter + 1 INTO counter;
    
    WHILE counter <= 10 DO
    	CALL IniciarSala(new.IDExperiencia, 0, counter);
        SELECT counter + 1 INTO counter;
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
    	IF NOT EXISTS (SELECT * FROM mysql.roles_mapping WHERE User = utilizador AND Host = 'localhost' AND Role = 'AdministradorAplicacao') THEN
    		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Está a tentar inserir uma experiência por outro utilizador!';
		END IF;
    END IF;
    
    IF NOT EXISTS (SELECT * FROM mysql.roles_mapping WHERE User = new.Investigador AND Host = 'localhost' AND Role = 'Investigador') THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Deve atribuir um investigador a uma experiencia!';
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
    
    IF new.TemperaturaAvisoMaximo > new.TemperaturaMaxima THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A temperatura de aviso maximo não pode ser superior à temperatura maxima!';
    END IF;
    
    IF new.TemperaturaAvisoMinimo < new.TemperaturaMinima THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A temperatura de aviso minimo não pode ser inferior à temperatura minima!';
    END IF;
    
    IF new.DataHoraInicioExperiência IS NOT NULL THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Só pode iniciar uma experiência depois de estar criada!';
    END IF;
    
    IF new.DataHoraFimExperiência IS NOT NULL THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Não pode terminar uma experiência que ainda não começou!';
    END IF;
    
    IF new.DataHoraCriaçãoExperiência < (NOW() - INTERVAL 5 MINUTE) OR new.DataHoraCriaçãoExperiência > (NOW() + INTERVAL 5 MINUTE) THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A data de criação não deve ser alterada!';
    END IF;
    
END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `ExperienciaUpdateAfter`;
DELIMITER $$
CREATE TRIGGER `ExperienciaUpdateAfter` AFTER UPDATE ON `experiencia` FOR EACH ROW BEGIN

	IF 	old.NúmeroRatos <> new.NúmeroRatos THEN
    	CALL EditarNumRatosSala(new.IDExperiencia, new.NúmeroRatos, 1);
    END IF;

END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `ExperienciaUpdateBefore`;
DELIMITER $$
CREATE TRIGGER `ExperienciaUpdateBefore` BEFORE UPDATE ON `experiencia` FOR EACH ROW BEGIN

	DECLARE utilizador VARCHAR(200); 
    SELECT SUBSTRING_INDEX(user(), '@', 2) INTO utilizador;
	IF NOT new.Investigador = utilizador THEN
    	IF NOT EXISTS (SELECT * FROM mysql.roles_mapping WHERE User = utilizador AND Host = 'localhost' AND (Role = 'AdministradorAplicacao' OR Role = 'WriteMySql')) THEN
    		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Está a tentar editar uma experiência de outro utilizador!';
		END IF;
	END IF;
    
    IF old.DataHoraInicioExperiência IS NOT NULL THEN
    	IF old.DataHoraInicioExperiência <> new.DataHoraInicioExperiência THEN
        	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Não pode alterar a data/hora de inicio de uma experiencia que está ou já tenha decorrido!';
        END IF;
        
        IF old.DataHoraFimExperiência IS NOT NULL THEN
        	IF old.DataHoraFimExperiência <> new.DataHoraFimExperiência THEN
            	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Não pode alterar a data/hora de fim de uma experiencia que já tenha decorrido!';
            END IF;
        END IF;
        
        IF new.DataHoraFimExperiência < old.DataHoraInicioExperiência THEN
        	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A data/hora de fim da experiência não podem ser menores que a data/hora de inicio!';
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
    
    IF old.DataHoraInicioExperiência IS NULL AND new.DataHoraFimExperiência IS NOT NULL THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Não pode terminar uma experiencia que ainda não começou!';
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
    
    IF new.TemperaturaAvisoMaximo > new.TemperaturaMaxima THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A temperatura de aviso maximo não pode ser superior à temperatura maxima!';
    END IF;
    
    IF new.TemperaturaAvisoMinimo < new.TemperaturaMinima THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A temperatura de aviso minimo não pode ser inferior à temperatura minima!';
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
) ENGINE=InnoDB AUTO_INCREMENT=236 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `medicoesnaoconformes`
--

INSERT INTO `medicoesnaoconformes` (`IDMedicao`, `IDExperiencia`, `RegistoRecebido`, `TipoMedicao`, `TipoDado`) VALUES
(1, NULL, '{\"Hora\": \"2024-05-13 19:10:45.937641\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(2, NULL, '{\"Hora\": \"2024-05-13 19:10:47.964215\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(3, NULL, '{\"Hora\": \"2024-05-13 19:11:01.956197\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(4, NULL, '{\"Hora\": \"2024-05-13 19:11:02.950770\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(5, NULL, '{\"Hora\": \"2024-05-13 19:11:02.984920\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(6, NULL, '{\"Hora\": \"2024-05-13 19:11:08.985978\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(7, NULL, '{\"Hora\": \"2024-05-13 19:11:10.960955\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(8, NULL, '{\"Hora\": \"2024-05-13 19:11:11.989239\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(9, NULL, '{\"Hora\": \"2024-05-13 19:11:12.962163\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(10, NULL, '{\"Hora\": \"2024-05-13 19:11:20.990907\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(11, 39, '{\"Hora\": \"2024-05-13 19:11:23.994292\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(12, 39, '{\"Hora\": \"2024-05-13 19:11:26.994582\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(13, 39, '{\"Hora\": \"2024-05-13 19:11:28.989752\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(14, 39, '{\"Hora\": \"2024-05-13 19:13:27.536485\", \"Leitura\": \"-50\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(15, 39, '{\"Hora\": \"2024-05-13 19:13:27.537391\", \"Leitura\": \"-49\", \"Sensor\": \"3\"}', 'Temperatura', 'Outlier'),
(16, 39, '{\"Hora\": \"2024-05-13 19:13:28.551437\", \"Leitura\": \"-49\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(17, NULL, '{\"Hora\": \"2024-05-13 19:13:28.552446\", \"Leitura\": \"-48\", \"Sensor\": \"3\"}', 'Temperatura', 'Outlier'),
(18, NULL, '{\"Hora\": \"2024-05-13 19:11:32.998829\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(19, NULL, '{\"Hora\": \"2024-05-13 19:13:29.561354\", \"Leitura\": \"-48\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(20, NULL, '{\"Hora\": \"2024-05-13 19:13:29.561933\", \"Leitura\": \"-47\", \"Sensor\": \"3\"}', 'Temperatura', 'Outlier'),
(21, NULL, '{\"Hora\": \"2024-05-13 19:13:30.567154\", \"Leitura\": \"-47\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(22, NULL, '{\"Hora\": \"2024-05-13 19:13:30.569093\", \"Leitura\": \"-46\", \"Sensor\": \"3\"}', 'Temperatura', 'Outlier'),
(23, NULL, '{\"Hora\": \"2024-05-13 19:13:31.573823\", \"Leitura\": \"-46\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(24, NULL, '{\"Hora\": \"2024-05-13 19:13:31.574723\", \"Leitura\": \"-45\", \"Sensor\": \"3\"}', 'Temperatura', 'Outlier'),
(25, NULL, '{\"Hora\": \"2024-05-13 19:11:36.002428\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(26, NULL, '{\"Hora\": \"2024-05-13 19:13:32.582905\", \"Leitura\": \"-45\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(27, NULL, '{\"Hora\": \"2024-05-13 19:13:32.583901\", \"Leitura\": \"-44\", \"Sensor\": \"3\"}', 'Temperatura', 'Outlier'),
(28, NULL, '{\"Hora\": \"2024-05-13 19:13:33.592210\", \"Leitura\": \"-44\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(29, NULL, '{\"Hora\": \"2024-05-13 19:13:33.593262\", \"Leitura\": \"-43\", \"Sensor\": \"3\"}', 'Temperatura', 'Outlier'),
(30, NULL, '{\"Hora\": \"2024-05-13 19:13:34.598674\", \"Leitura\": \"-43\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(31, NULL, '{\"Hora\": \"2024-05-13 19:13:34.599633\", \"Leitura\": \"-42\", \"Sensor\": \"3\"}', 'Temperatura', 'Outlier'),
(32, NULL, '{\"Hora\": \"2024-05-13 19:13:35.605801\", \"Leitura\": \"-42\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(33, NULL, '{\"Hora\": \"2024-05-13 19:13:35.606812\", \"Leitura\": \"-41\", \"Sensor\": \"3\"}', 'Temperatura', 'Outlier'),
(34, NULL, '{\"Hora\": \"2024-05-13 19:13:36.613210\", \"Leitura\": \"-41\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(35, NULL, '{\"Hora\": \"2024-05-13 19:13:36.614128\", \"Leitura\": \"-40\", \"Sensor\": \"3\"}', 'Temperatura', 'Outlier'),
(36, NULL, '{\"Hora\": \"2024-05-13 19:13:37.619976\", \"Leitura\": \"-40\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(37, NULL, '{\"Hora\": \"2024-05-13 19:13:37.621680\", \"Leitura\": \"-39\", \"Sensor\": \"3\"}', 'Temperatura', 'Outlier'),
(38, NULL, '{\"Hora\": \"2024-05-13 19:13:38.632001\", \"Leitura\": \"-39\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(39, NULL, '{\"Hora\": \"2024-05-13 19:13:38.632911\", \"Leitura\": \"-38\", \"Sensor\": \"3\"}', 'Temperatura', 'Outlier'),
(40, NULL, '{\"Hora\": \"2024-05-13 19:13:39.639437\", \"Leitura\": \"-38\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(41, NULL, '{\"Hora\": \"2024-05-13 19:11:42.003366\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(42, NULL, '{\"Hora\": \"2024-05-13 19:11:42.989424\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(43, NULL, '{\"Hora\": \"2024-05-13 19:11:49.998456\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(44, NULL, '{\"Hora\": \"2024-05-13 19:11:50.960865\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(45, NULL, '{\"Hora\": \"2024-05-13 19:11:54.993603\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(46, NULL, '{\"Hora\": \"2024-05-13 19:11:59.003699\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(47, NULL, '{\"Hora\": \"2024-05-13 19:12:04.969309\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(48, NULL, '{\"Hora\": \"2024-05-13 19:12:13.173934\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(49, NULL, '{\"Hora\": \"2024-05-13 19:12:16.206053\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(50, NULL, '{\"Hora\": \"2024-05-13 19:12:21.230962\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(51, NULL, '{\"Hora\": \"2024-05-13 19:12:25.232749\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(52, NULL, '{\"Hora\": \"2024-05-13 19:12:27.312440\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(53, NULL, '{\"Hora\": \"2024-05-13 19:12:47.675739\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(54, NULL, '{\"Hora\": \"2024-05-13 19:12:48.626034\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(55, NULL, '{\"Hora\": \"2024-05-13 19:12:59.473546\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(56, NULL, '{\"Hora\": \"2024-05-13 19:13:47.307972\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(57, NULL, '{\"Hora\": \"2024-05-13 19:15:08.402793\", \"Leitura\": \"-50\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(58, NULL, '{\"Hora\": \"2024-05-13 19:15:08.403742\", \"Leitura\": \"-49\", \"Sensor\": \"3\"}', 'Temperatura', 'Outlier'),
(59, NULL, '{\"Hora\": \"2024-05-13 19:15:09.411922\", \"Leitura\": \"-49\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(60, NULL, '{\"Hora\": \"2024-05-13 19:15:09.412886\", \"Leitura\": \"-48\", \"Sensor\": \"3\"}', 'Temperatura', 'Outlier'),
(61, NULL, '{\"Solucao\": \"0-0-6-11-9-3-28-11-0-12\"}', 'Movimento', 'Dado Errado'),
(62, NULL, '{\"Hora\": \"2024-05-13 19:15:10.422000\", \"Leitura\": \"-48\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(63, NULL, '{\"Hora\": \"2000-01-01 00:00:00\", \"SalaOrigem\": \"0\", \"SalaDestino\": \"0\"}', 'Movimento', 'Dado Errado'),
(64, NULL, '{\"Hora\": \"2024-05-13 19:15:10.422912\", \"Leitura\": \"-47\", \"Sensor\": \"3\"}', 'Temperatura', 'Outlier'),
(65, NULL, '{\"Hora\": \"2024-05-13 19:14:16.604228\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(66, NULL, '{\"Hora\": \"2024-05-13 19:15:11.428895\", \"Leitura\": \"-47\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(67, NULL, '{\"Hora\": \"2024-05-13 19:15:11.429794\", \"Leitura\": \"-46\", \"Sensor\": \"3\"}', 'Temperatura', 'Outlier'),
(68, NULL, '{\"Hora\": \"2024-05-13 19:14:19.604789\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(69, NULL, '{\"Hora\": \"2024-05-13 19:15:12.432330\", \"Leitura\": \"-46\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(70, NULL, '{\"Hora\": \"2024-05-13 19:15:12.433337\", \"Leitura\": \"-45\", \"Sensor\": \"3\"}', 'Temperatura', 'Outlier'),
(71, NULL, '{\"Hora\": \"2024-05-13 19:15:13.439810\", \"Leitura\": \"-45\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(72, NULL, '{\"Hora\": \"2024-05-13 19:15:13.440873\", \"Leitura\": \"-44\", \"Sensor\": \"3\"}', 'Temperatura', 'Outlier'),
(73, NULL, '{\"Hora\": \"2024-05-13 19:14:28.608738\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(74, NULL, '{\"Hora\": \"2024-05-13 19:15:14.443973\", \"Leitura\": \"-44\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(75, NULL, '{\"Hora\": \"2024-05-13 19:15:14.444980\", \"Leitura\": \"-43\", \"Sensor\": \"3\"}', 'Temperatura', 'Outlier'),
(76, NULL, '{\"Hora\": \"2024-05-13 19:15:15.452739\", \"Leitura\": \"-43\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(77, NULL, '{\"Hora\": \"2024-05-13 19:15:15.453676\", \"Leitura\": \"-42\", \"Sensor\": \"3\"}', 'Temperatura', 'Outlier'),
(78, NULL, '{\"Hora\": \"2024-05-13 19:15:16.460060\", \"Leitura\": \"-42\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(79, NULL, '{\"Hora\": \"2024-05-13 19:15:16.460563\", \"Leitura\": \"-41\", \"Sensor\": \"3\"}', 'Temperatura', 'Outlier'),
(80, NULL, '{\"Hora\": \"2024-05-13 19:14:34.609718\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(81, NULL, '{\"Hora\": \"2024-05-13 19:15:17.467524\", \"Leitura\": \"-41\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(82, NULL, '{\"Hora\": \"2024-05-13 19:15:17.468086\", \"Leitura\": \"-40\", \"Sensor\": \"3\"}', 'Temperatura', 'Outlier'),
(83, NULL, '{\"Hora\": \"2024-05-13 19:15:18.479828\", \"Leitura\": \"-40\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(84, NULL, '{\"Hora\": \"2024-05-13 19:14:37.612766\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(85, NULL, '{\"Hora\": \"2024-05-13 19:15:18.480734\", \"Leitura\": \"-39\", \"Sensor\": \"3\"}', 'Temperatura', 'Outlier'),
(86, NULL, '{\"Hora\": \"2024-05-13 19:15:19.489992\", \"Leitura\": \"-39\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(87, NULL, '{\"Hora\": \"2024-05-13 19:15:19.490995\", \"Leitura\": \"-38\", \"Sensor\": \"3\"}', 'Temperatura', 'Outlier'),
(88, NULL, '{\"Hora\": \"2024-05-13 19:15:20.500426\", \"Leitura\": \"-38\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(89, NULL, '{\"Hora\": \"2024-05-13 19:14:43.613763\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(90, NULL, '{\"Hora\": \"2024-05-13 19:14:47.606780\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(91, NULL, '{\"Hora\": \"2024-05-13 19:14:48.606299\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(92, NULL, '{\"Hora\": \"2024-05-13 19:14:49.617831\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(93, NULL, '{\"Hora\": \"2024-05-13 19:14:58.618998\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(94, NULL, '{\"Hora\": \"2024-05-13 19:15:01.619774\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(95, NULL, '{\"Hora\": \"2024-05-13 19:15:07.628548\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(96, NULL, '{\"Hora\": \"2024-05-13 19:15:13.629562\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(97, NULL, '{\"Hora\": \"2024-05-13 19:15:15.619335\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(98, NULL, '{\"Hora\": \"2024-05-13 19:15:16.630057\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(99, NULL, '{\"Hora\": \"2024-05-13 19:15:18.608970\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(100, NULL, '{\"Hora\": \"2024-05-13 19:15:18.619993\", \"SalaOrigem\": \"3\", \"SalaDestino\": \"10\"}', 'Movimento', 'Dado Errado'),
(101, NULL, '{\"Hora\": \"2024-05-13 19:15:19.630745\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(102, NULL, '{\"Hora\": \"2024-05-13 19:15:25.632160\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(103, NULL, '{\"Hora\": \"2024-05-13 19:15:31.632905\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(104, NULL, '{\"Hora\": \"2024-05-13 19:15:34.633737\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(105, NULL, '{\"Hora\": \"2024-05-13 19:15:36.630352\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(106, NULL, '{\"Hora\": \"2024-05-13 19:15:38.630627\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(107, NULL, '{\"Hora\": \"2024-05-13 19:15:41.620733\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(108, NULL, '{\"Hora\": \"2024-05-13 19:15:42.635225\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(109, NULL, '{\"Hora\": \"2024-05-13 19:15:43.639207\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(110, 40, '{\"Hora\": \"2024-05-13 19:15:46.640011\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(111, 40, '{\"Hora\": \"2024-05-13 19:15:49.615736\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(112, 40, '{\"Hora\": \"2024-05-13 19:15:50.635965\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(113, NULL, '{\"Hora\": \"2024-05-13 19:15:53.620611\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(114, NULL, '{\"Hora\": \"2024-05-13 19:16:49.161486\", \"Leitura\": \"-50\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(115, NULL, '{\"Hora\": \"2024-05-13 19:16:49.162448\", \"Leitura\": \"-49\", \"Sensor\": \"3\"}', 'Temperatura', 'Outlier'),
(116, NULL, '{\"Hora\": \"2024-05-13 19:16:50.169107\", \"Leitura\": \"-49\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(117, NULL, '{\"Hora\": \"2024-05-13 19:16:50.169107\", \"Leitura\": \"-48\", \"Sensor\": \"3\"}', 'Temperatura', 'Outlier'),
(118, NULL, '{\"Hora\": \"2024-05-13 19:15:55.644275\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(119, NULL, '{\"Hora\": \"2024-05-13 19:16:51.171048\", \"Leitura\": \"-48\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(120, NULL, '{\"Hora\": \"2024-05-13 19:16:51.171555\", \"Leitura\": \"-47\", \"Sensor\": \"3\"}', 'Temperatura', 'Outlier'),
(121, NULL, '{\"Hora\": \"2024-05-13 19:16:52.177777\", \"Leitura\": \"-47\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(122, NULL, '{\"Hora\": \"2024-05-13 19:16:52.178276\", \"Leitura\": \"-46\", \"Sensor\": \"3\"}', 'Temperatura', 'Outlier'),
(123, NULL, '{\"Hora\": \"2024-05-13 19:16:53.181376\", \"Leitura\": \"-46\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(124, NULL, '{\"Hora\": \"2024-05-13 19:16:53.182290\", \"Leitura\": \"-45\", \"Sensor\": \"3\"}', 'Temperatura', 'Outlier'),
(125, NULL, '{\"Hora\": \"2024-05-13 19:16:54.187923\", \"Leitura\": \"-45\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(126, NULL, '{\"Hora\": \"2024-05-13 19:15:57.635280\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(127, NULL, '{\"Hora\": \"2024-05-13 19:16:54.188457\", \"Leitura\": \"-44\", \"Sensor\": \"3\"}', 'Temperatura', 'Outlier'),
(128, NULL, '{\"Hora\": \"2024-05-13 19:15:58.644904\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(129, NULL, '{\"Hora\": \"2024-05-13 19:16:55.195991\", \"Leitura\": \"-44\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(130, NULL, '{\"Hora\": \"2024-05-13 19:16:55.196994\", \"Leitura\": \"-43\", \"Sensor\": \"3\"}', 'Temperatura', 'Outlier'),
(131, NULL, '{\"Hora\": \"2024-05-13 19:16:56.204184\", \"Leitura\": \"-43\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(132, NULL, '{\"Hora\": \"2024-05-13 19:16:56.205092\", \"Leitura\": \"-42\", \"Sensor\": \"3\"}', 'Temperatura', 'Outlier'),
(133, NULL, '{\"Hora\": \"2024-05-13 19:16:00.639388\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(134, NULL, '{\"Hora\": \"2024-05-13 19:16:57.218312\", \"Leitura\": \"-42\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(135, NULL, '{\"Hora\": \"2024-05-13 19:16:57.218812\", \"Leitura\": \"-41\", \"Sensor\": \"3\"}', 'Temperatura', 'Outlier'),
(136, NULL, '{\"Hora\": \"2024-05-13 19:16:58.225185\", \"Leitura\": \"-41\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(137, NULL, '{\"Hora\": \"2024-05-13 19:16:58.226090\", \"Leitura\": \"-40\", \"Sensor\": \"3\"}', 'Temperatura', 'Outlier'),
(138, NULL, '{\"Hora\": \"2024-05-13 19:16:59.235086\", \"Leitura\": \"-40\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(139, NULL, '{\"Hora\": \"2024-05-13 19:16:59.235992\", \"Leitura\": \"-39\", \"Sensor\": \"3\"}', 'Temperatura', 'Outlier'),
(140, NULL, '{\"Hora\": \"2024-05-13 19:17:00.238465\", \"Leitura\": \"-39\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(141, NULL, '{\"Hora\": \"2024-05-13 19:17:00.239459\", \"Leitura\": \"-38\", \"Sensor\": \"3\"}', 'Temperatura', 'Outlier'),
(142, NULL, '{\"Hora\": \"2024-05-13 19:17:01.249938\", \"Leitura\": \"-38\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(143, NULL, '{\"Hora\": \"2024-05-13 19:16:07.646490\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(144, NULL, '{\"Hora\": \"2024-05-13 19:16:11.618138\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(145, NULL, '{\"Hora\": \"2024-05-13 19:16:13.637157\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(146, NULL, '{\"Hora\": \"2024-05-13 19:16:13.647667\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(147, NULL, '{\"Hora\": \"2024-05-13 19:16:16.640938\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(148, NULL, '{\"Hora\": \"2024-05-13 19:16:22.632643\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(149, NULL, '{\"Hora\": \"2024-05-13 19:16:22.648678\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(150, NULL, '{\"Hora\": \"2024-05-13 19:16:25.649039\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(151, NULL, '{\"Hora\": \"2024-05-13 19:16:31.649935\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(152, NULL, '{\"Hora\": \"2024-05-13 19:16:33.650507\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(153, NULL, '{\"Hora\": \"2024-05-13 19:18:30.041207\", \"Leitura\": \"-49\", \"Sensor\": \"3\"}', 'Temperatura', 'Outlier'),
(154, NULL, '{\"Hora\": \"2024-05-13 19:18:30.040747\", \"Leitura\": \"-50\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(155, NULL, '{\"Hora\": \"2024-05-13 19:18:31.051178\", \"Leitura\": \"-48\", \"Sensor\": \"3\"}', 'Temperatura', 'Outlier'),
(156, NULL, '{\"Hora\": \"2024-05-13 19:18:31.050672\", \"Leitura\": \"-49\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(157, NULL, '{\"Hora\": \"2024-05-13 19:18:32.060045\", \"Leitura\": \"-47\", \"Sensor\": \"3\"}', 'Temperatura', 'Outlier'),
(158, NULL, '{\"Hora\": \"2024-05-13 19:18:32.059546\", \"Leitura\": \"-48\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(159, NULL, '{\"Hora\": \"2024-05-13 19:18:33.072163\", \"Leitura\": \"-46\", \"Sensor\": \"3\"}', 'Temperatura', 'Outlier'),
(160, NULL, '{\"Hora\": \"2024-05-13 19:18:33.072163\", \"Leitura\": \"-47\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(161, NULL, '{\"Hora\": \"2024-05-13 19:18:34.084132\", \"Leitura\": \"-45\", \"Sensor\": \"3\"}', 'Temperatura', 'Outlier'),
(162, NULL, '{\"Hora\": \"2024-05-13 19:18:34.083256\", \"Leitura\": \"-46\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(163, NULL, '{\"Hora\": \"2024-05-13 19:18:35.088204\", \"Leitura\": \"-44\", \"Sensor\": \"3\"}', 'Temperatura', 'Outlier'),
(164, NULL, '{\"Hora\": \"2024-05-13 19:18:35.088204\", \"Leitura\": \"-45\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(165, NULL, '{\"Hora\": \"2024-05-13 19:18:36.100831\", \"Leitura\": \"-43\", \"Sensor\": \"3\"}', 'Temperatura', 'Outlier'),
(166, NULL, '{\"Hora\": \"2024-05-13 19:18:36.096993\", \"Leitura\": \"-44\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(167, NULL, '{\"Hora\": \"2024-05-13 19:18:37.107427\", \"Leitura\": \"-42\", \"Sensor\": \"3\"}', 'Temperatura', 'Outlier'),
(168, NULL, '{\"Hora\": \"2024-05-13 19:18:37.106422\", \"Leitura\": \"-43\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(169, NULL, '{\"Hora\": \"2024-05-13 19:18:38.115774\", \"Leitura\": \"-41\", \"Sensor\": \"3\"}', 'Temperatura', 'Outlier'),
(170, NULL, '{\"Hora\": \"2024-05-13 19:18:38.115203\", \"Leitura\": \"-42\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(171, NULL, '{\"Hora\": \"2024-05-13 19:18:39.129998\", \"Leitura\": \"-40\", \"Sensor\": \"3\"}', 'Temperatura', 'Outlier'),
(172, NULL, '{\"Hora\": \"2024-05-13 19:18:39.129030\", \"Leitura\": \"-41\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(173, NULL, '{\"Hora\": \"2024-05-13 19:18:40.140686\", \"Leitura\": \"-39\", \"Sensor\": \"3\"}', 'Temperatura', 'Outlier'),
(174, NULL, '{\"Hora\": \"2024-05-13 19:18:40.140091\", \"Leitura\": \"-40\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(175, NULL, '{\"Hora\": \"2024-05-13 19:18:41.155087\", \"Leitura\": \"-39\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(176, NULL, '{\"Hora\": \"2024-05-13 19:18:42.162465\", \"Leitura\": \"-38\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(177, NULL, '{\"Hora\": \"2024-05-13 19:18:44.189361\", \"Leitura\": \"-37\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(178, NULL, '{\"Hora\": \"2024-05-13 19:16:40.659720\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(179, NULL, '{\"Hora\": \"2024-05-13 19:16:42.623784\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(180, NULL, '{\"Hora\": \"2024-05-13 19:16:43.660040\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(181, NULL, '{\"Hora\": \"2024-05-13 19:16:46.660371\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(182, NULL, '{\"Hora\": \"2024-05-13 19:16:47.643417\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(183, NULL, '{\"Hora\": \"2024-05-13 19:16:50.649826\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(184, NULL, '{\"Hora\": \"2024-05-13 19:16:52.665391\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(185, NULL, '{\"Hora\": \"2024-05-13 19:16:55.669234\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(186, NULL, '{\"Hora\": \"2024-05-13 19:16:58.671684\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(187, NULL, '{\"Hora\": \"2024-05-13 19:17:02.645046\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(188, NULL, '{\"Hora\": \"2024-05-13 19:17:04.672980\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(189, NULL, '{\"Hora\": \"2024-05-13 19:17:10.676638\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(190, NULL, '{\"Hora\": \"2024-05-13 19:17:14.638697\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(191, NULL, '{\"Hora\": \"2024-05-13 19:17:17.656070\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(192, NULL, '{\"Hora\": \"2024-05-13 19:17:18.655948\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(193, NULL, '{\"Hora\": \"2024-05-13 19:17:20.673721\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(194, NULL, '{\"Hora\": \"2024-05-13 19:17:22.681354\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(195, NULL, '{\"Hora\": \"2024-05-13 19:17:31.682841\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(196, NULL, '{\"Hora\": \"2024-05-13 19:17:38.646454\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(197, NULL, '{\"Hora\": \"2024-05-13 19:17:39.678713\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(198, NULL, '{\"Hora\": \"2024-05-13 19:17:40.686988\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(199, NULL, '{\"Hora\": \"2024-05-13 19:17:43.666731\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(200, NULL, '{\"Hora\": \"2024-05-13 19:17:43.697975\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(201, NULL, '{\"Hora\": \"2024-05-13 19:17:46.698780\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(202, 41, '{\"Hora\": \"2024-05-13 19:21:10.857180\", \"Leitura\": \"-50\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(203, 41, '{\"Hora\": \"2024-05-13 19:21:11.865634\", \"Leitura\": \"-49\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(204, 41, '{\"Hora\": \"2024-05-13 19:21:12.874283\", \"Leitura\": \"-48\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(205, 41, '{\"Hora\": \"2024-05-13 19:17:55.713675\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(206, 41, '{\"Hora\": \"2024-05-13 19:21:13.888053\", \"Leitura\": \"-47\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(207, NULL, '{\"Hora\": \"2024-05-13 19:21:14.896917\", \"Leitura\": \"-46\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(208, NULL, '{\"Hora\": \"2024-05-13 19:21:15.908212\", \"Leitura\": \"-45\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(209, NULL, '{\"Hora\": \"2024-05-13 19:21:16.922532\", \"Leitura\": \"-44\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(210, NULL, '{\"Hora\": \"2024-05-13 19:21:17.934741\", \"Leitura\": \"-43\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(211, NULL, '{\"Hora\": \"2024-05-13 19:17:58.714646\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(212, NULL, '{\"Hora\": \"2024-05-13 19:21:18.943347\", \"Leitura\": \"-42\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(213, NULL, '{\"Hora\": \"2024-05-13 19:21:19.950315\", \"Leitura\": \"-41\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(214, NULL, '{\"Hora\": \"2024-05-13 19:21:20.954078\", \"Leitura\": \"-40\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(215, NULL, '{\"Hora\": \"2024-05-13 19:21:21.963053\", \"Leitura\": \"-39\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(216, NULL, '{\"Hora\": \"2024-05-13 19:18:01.717157\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(217, NULL, '{\"Hora\": \"2024-05-13 19:21:22.975992\", \"Leitura\": \"-38\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(218, NULL, '{\"Hora\": \"2024-05-13 19:21:23.978688\", \"Leitura\": \"-37\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(219, NULL, '{\"Hora\": \"2024-05-13 19:21:24.991149\", \"Leitura\": \"-36\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(220, NULL, '{\"Hora\": \"2024-05-13 19:18:03.675088\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(221, NULL, '{\"Hora\": \"2024-05-13 19:18:03.682594\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(222, NULL, '{\"Hora\": \"2024-05-13 19:21:26.000288\", \"Leitura\": \"-35\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(223, NULL, '{\"Hora\": \"2024-05-13 19:21:27.016351\", \"Leitura\": \"-34\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(224, NULL, '{\"Hora\": \"2024-05-13 19:21:28.027483\", \"Leitura\": \"-33\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(225, NULL, '{\"Hora\": \"2024-05-13 19:18:04.717926\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(226, NULL, '{\"Hora\": \"2024-05-13 19:21:29.036646\", \"Leitura\": \"-32\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(227, NULL, '{\"Hora\": \"2024-05-13 19:21:30.046235\", \"Leitura\": \"-31\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(228, NULL, '{\"Hora\": \"2024-05-13 19:21:31.059241\", \"Leitura\": \"-30\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(229, NULL, '{\"Hora\": \"2024-05-13 19:21:32.071261\", \"Leitura\": \"-29\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(230, NULL, '{\"Hora\": \"2024-05-13 19:21:33.078911\", \"Leitura\": \"-28\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(231, NULL, '{\"Hora\": \"2024-05-13 19:21:34.092324\", \"Leitura\": \"-27\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(232, NULL, '{\"Hora\": \"2024-05-13 19:18:10.680732\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(233, NULL, '{\"Hora\": \"2024-05-13 19:21:35.102729\", \"Leitura\": \"-26\", \"Sensor\": \"2\"}', 'Temperatura', 'Outlier'),
(234, NULL, '{\"Hora\": \"2024-05-13 19:18:12.706483\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(235, NULL, '{\"Hora\": \"2024-05-13 19:18:13.722445\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado');

--
-- Triggers `medicoesnaoconformes`
--
DROP TRIGGER IF EXISTS `MedicoesNaoConformesInsertBefore`;
DELIMITER $$
CREATE TRIGGER `MedicoesNaoConformesInsertBefore` BEFORE INSERT ON `medicoesnaoconformes` FOR EACH ROW BEGIN

	DECLARE idExperiencia INT;
    CALL ObterExperienciaADecorrer(idExperiencia);
    
    SET new.IDExperiencia = idExperiencia;

END
$$
DELIMITER ;

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
  `IDExperiencia` int(11) DEFAULT NULL,
  PRIMARY KEY (`IDMedição`),
  KEY `ExpPassagem` (`IDExperiencia`)
) ENGINE=InnoDB AUTO_INCREMENT=689 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `medicoespassagem`
--

INSERT INTO `medicoespassagem` (`IDMedição`, `DataHora`, `SalaOrigem`, `SalaDestino`, `IDExperiencia`) VALUES
(1, '2024-05-13 19:10:39', 5, 7, NULL),
(2, '2024-05-13 19:10:41', 2, 5, NULL),
(3, '2024-05-13 19:10:41', 5, 7, NULL),
(4, '2024-05-13 19:10:41', 1, 2, NULL),
(5, '2024-05-13 19:10:42', 4, 5, NULL),
(6, '2024-05-13 19:10:42', 8, 9, NULL),
(7, '2024-05-13 19:10:42', 3, 2, NULL),
(8, '2024-05-13 19:10:42', 2, 5, NULL),
(9, '2024-05-13 19:10:42', 5, 7, NULL),
(10, '2024-05-13 19:10:42', 2, 4, NULL),
(11, '2024-05-13 19:10:44', 1, 2, NULL),
(12, '2024-05-13 19:10:45', 5, 7, NULL),
(13, '2024-05-13 19:10:45', 2, 4, NULL),
(14, '2024-05-13 19:10:47', 1, 2, NULL),
(15, '2024-05-13 19:10:48', 7, 5, NULL),
(16, '2024-05-13 19:10:48', 3, 2, NULL),
(17, '2024-05-13 19:10:48', 2, 4, NULL),
(18, '2024-05-13 19:10:49', 2, 5, NULL),
(19, '2024-05-13 19:10:50', 7, 5, NULL),
(20, '2024-05-13 19:10:50', 4, 5, NULL),
(21, '2024-05-13 19:10:50', 3, 2, NULL),
(22, '2024-05-13 19:10:51', 7, 5, NULL),
(23, '2024-05-13 19:10:51', 2, 4, NULL),
(24, '2024-05-13 19:10:52', 7, 5, NULL),
(25, '2024-05-13 19:10:52', 5, 6, NULL),
(26, '2024-05-13 19:10:52', 2, 4, NULL),
(27, '2024-05-13 19:10:52', 2, 5, NULL),
(28, '2024-05-13 19:10:53', 5, 7, NULL),
(29, '2024-05-13 19:10:53', 5, 7, NULL),
(30, '2024-05-13 19:10:53', 1, 2, NULL),
(31, '2024-05-13 19:10:54', 9, 7, NULL),
(32, '2024-05-13 19:10:54', 2, 4, NULL),
(33, '2024-05-13 19:10:56', 7, 5, NULL),
(34, '2024-05-13 19:10:56', 4, 5, NULL),
(35, '2024-05-13 19:10:56', 1, 2, NULL),
(36, '2024-05-13 19:10:57', 7, 5, NULL),
(37, '2024-05-13 19:10:58', 5, 6, NULL),
(38, '2024-05-13 19:10:59', 6, 8, NULL),
(39, '2024-05-13 19:10:59', 5, 6, NULL),
(40, '2024-05-13 19:10:59', 4, 5, NULL),
(41, '2024-05-13 19:10:59', 1, 2, NULL),
(42, '2024-05-13 19:11:00', 4, 5, NULL),
(43, '2024-05-13 19:11:00', 7, 5, NULL),
(44, '2024-05-13 19:11:00', 2, 5, NULL),
(45, '2024-05-13 19:11:00', 2, 4, NULL),
(46, '2024-05-13 19:11:01', 2, 5, NULL),
(47, '2024-05-13 19:11:02', 8, 9, NULL),
(48, '2024-05-13 19:11:02', 4, 5, NULL),
(49, '2024-05-13 19:11:02', 5, 7, NULL),
(50, '2024-05-13 19:11:02', 1, 2, NULL),
(51, '2024-05-13 19:11:03', 5, 7, NULL),
(52, '2024-05-13 19:11:03', 5, 7, NULL),
(53, '2024-05-13 19:11:04', 3, 2, NULL),
(54, '2024-05-13 19:11:05', 6, 8, NULL),
(55, '2024-05-13 19:11:05', 3, 2, NULL),
(56, '2024-05-13 19:11:05', 3, 2, NULL),
(57, '2024-05-13 19:11:06', 5, 6, NULL),
(58, '2024-05-13 19:11:06', 6, 8, NULL),
(59, '2024-05-13 19:11:06', 2, 5, NULL),
(60, '2024-05-13 19:11:06', 5, 6, NULL),
(61, '2024-05-13 19:11:06', 2, 4, NULL),
(62, '2024-05-13 19:11:07', 5, 6, NULL),
(63, '2024-05-13 19:11:08', 7, 5, NULL),
(64, '2024-05-13 19:11:08', 1, 2, NULL),
(65, '2024-05-13 19:11:09', 7, 5, NULL),
(66, '2024-05-13 19:11:09', 8, 9, NULL),
(67, '2024-05-13 19:11:09', 2, 4, NULL),
(68, '2024-05-13 19:11:11', 5, 6, NULL),
(69, '2024-05-13 19:11:11', 3, 2, NULL),
(70, '2024-05-13 19:11:12', 5, 7, NULL),
(71, '2024-05-13 19:11:13', 6, 8, NULL),
(72, '2024-05-13 19:11:13', 3, 2, NULL),
(73, '2024-05-13 19:11:13', 6, 8, NULL),
(74, '2024-05-13 19:11:14', 9, 7, NULL),
(75, '2024-05-13 19:11:14', 2, 4, NULL),
(76, '2024-05-13 19:11:14', 6, 8, NULL),
(77, '2024-05-13 19:11:14', 4, 5, NULL),
(78, '2024-05-13 19:11:14', 3, 2, NULL),
(79, '2024-05-13 19:11:15', 2, 4, NULL),
(80, '2024-05-13 19:11:15', 3, 2, NULL),
(81, '2024-05-13 19:11:15', 2, 5, NULL),
(82, '2024-05-13 19:11:16', 5, 6, NULL),
(83, '2024-05-13 19:11:17', 5, 7, NULL),
(84, '2024-05-13 19:11:17', 1, 2, NULL),
(85, '2024-05-13 19:11:18', 6, 8, NULL),
(86, '2024-05-13 19:11:18', 7, 5, NULL),
(87, '2024-05-13 19:11:18', 5, 6, NULL),
(88, '2024-05-13 19:11:18', 2, 4, NULL),
(89, '2024-05-13 19:11:18', 2, 5, NULL),
(90, '2024-05-13 19:11:20', 8, 10, NULL),
(91, '2024-05-13 19:11:20', 1, 2, NULL),
(92, '2024-05-13 19:11:21', 9, 7, NULL),
(93, '2024-05-13 19:11:21', 2, 4, NULL),
(94, '2024-05-13 19:11:22', 4, 5, NULL),
(95, '2024-05-13 19:11:23', 4, 5, NULL),
(96, '2024-05-13 19:11:23', 6, 8, 39),
(97, '2024-05-13 19:11:23', 3, 2, 39),
(98, '2024-05-13 19:11:24', 2, 4, 39),
(99, '2024-05-13 19:11:25', 6, 8, 39),
(100, '2024-05-13 19:11:25', 5, 7, 39),
(101, '2024-05-13 19:11:25', 5, 6, 39),
(102, '2024-05-13 19:11:26', 5, 7, 39),
(103, '2024-05-13 19:11:26', 2, 5, 39),
(104, '2024-05-13 19:11:26', 3, 2, 39),
(105, '2024-05-13 19:11:27', 7, 5, 39),
(106, '2024-05-13 19:11:28', 5, 6, 39),
(107, '2024-05-13 19:11:28', 8, 10, 39),
(108, '2024-05-13 19:11:28', 2, 5, 39),
(109, '2024-05-13 19:11:28', 8, 10, 39),
(110, '2024-05-13 19:11:29', 3, 2, 39),
(111, '2024-05-13 19:11:30', 2, 5, 39),
(112, '2024-05-13 19:11:31', 5, 7, 39),
(113, '2024-05-13 19:11:31', 3, 2, 39),
(114, '2024-05-13 19:11:32', 6, 8, 39),
(115, '2024-05-13 19:11:32', 7, 5, 39),
(116, '2024-05-13 19:11:32', 4, 5, 39),
(117, '2024-05-13 19:11:32', 1, 2, 39),
(118, '2024-05-13 19:11:33', 2, 5, NULL),
(119, '2024-05-13 19:11:33', 5, 7, NULL),
(120, '2024-05-13 19:11:35', 8, 9, NULL),
(121, '2024-05-13 19:11:36', 3, 2, NULL),
(122, '2024-05-13 19:11:36', 7, 5, NULL),
(123, '2024-05-13 19:11:36', 5, 6, NULL),
(124, '2024-05-13 19:11:36', 5, 7, NULL),
(125, '2024-05-13 19:11:36', 2, 5, NULL),
(126, '2024-05-13 19:11:39', 3, 2, NULL),
(127, '2024-05-13 19:11:39', 5, 7, NULL),
(128, '2024-05-13 19:11:39', 2, 5, NULL),
(129, '2024-05-13 19:11:39', 5, 7, NULL),
(130, '2024-05-13 19:11:40', 7, 5, NULL),
(131, '2024-05-13 19:11:41', 7, 5, NULL),
(132, '2024-05-13 19:11:42', 1, 2, NULL),
(133, '2024-05-13 19:11:42', 2, 5, NULL),
(134, '2024-05-13 19:11:42', 5, 6, NULL),
(135, '2024-05-13 19:11:43', 2, 4, NULL),
(136, '2024-05-13 19:11:43', 6, 8, NULL),
(137, '2024-05-13 19:11:44', 2, 5, NULL),
(138, '2024-05-13 19:11:45', 3, 2, NULL),
(139, '2024-05-13 19:11:45', 3, 2, NULL),
(140, '2024-05-13 19:11:45', 5, 7, NULL),
(141, '2024-05-13 19:11:46', 7, 5, NULL),
(142, '2024-05-13 19:11:47', 9, 7, NULL),
(143, '2024-05-13 19:11:48', 1, 2, NULL),
(144, '2024-05-13 19:11:49', 2, 5, NULL),
(145, '2024-05-13 19:11:49', 2, 4, NULL),
(146, '2024-05-13 19:11:49', 5, 7, NULL),
(147, '2024-05-13 19:11:49', 6, 8, NULL),
(148, '2024-05-13 19:11:51', 1, 2, NULL),
(149, '2024-05-13 19:11:51', 5, 6, NULL),
(150, '2024-05-13 19:11:52', 2, 4, NULL),
(151, '2024-05-13 19:11:52', 3, 2, NULL),
(152, '2024-05-13 19:11:53', 3, 2, NULL),
(153, '2024-05-13 19:11:54', 1, 2, NULL),
(154, '2024-05-13 19:11:54', 7, 5, NULL),
(155, '2024-05-13 19:11:55', 2, 4, NULL),
(156, '2024-05-13 19:11:57', 4, 5, NULL),
(157, '2024-05-13 19:11:57', 1, 2, NULL),
(158, '2024-05-13 19:11:58', 2, 4, NULL),
(159, '2024-05-13 19:11:58', 3, 2, NULL),
(160, '2024-05-13 19:11:58', 6, 8, NULL),
(161, '2024-05-13 19:11:59', 2, 5, NULL),
(162, '2024-05-13 19:12:00', 1, 2, NULL),
(163, '2024-05-13 19:12:00', 4, 5, NULL),
(164, '2024-05-13 19:12:00', 5, 7, NULL),
(165, '2024-05-13 19:12:02', 5, 7, NULL),
(166, '2024-05-13 19:12:02', 3, 2, NULL),
(167, '2024-05-13 19:12:03', 7, 5, NULL),
(168, '2024-05-13 19:12:03', 4, 5, NULL),
(169, '2024-05-13 19:12:03', 5, 7, NULL),
(170, '2024-05-13 19:12:03', 2, 4, NULL),
(171, '2024-05-13 19:12:04', 2, 5, NULL),
(172, '2024-05-13 19:12:04', 2, 4, NULL),
(173, '2024-05-13 19:12:04', 7, 5, NULL),
(174, '2024-05-13 19:12:06', 2, 5, NULL),
(175, '2024-05-13 19:12:06', 5, 7, NULL),
(176, '2024-05-13 19:12:07', 2, 4, NULL),
(177, '2024-05-13 19:12:07', 5, 7, NULL),
(178, '2024-05-13 19:12:09', 5, 7, NULL),
(179, '2024-05-13 19:12:11', 2, 5, NULL),
(180, '2024-05-13 19:12:12', 4, 5, NULL),
(181, '2024-05-13 19:12:12', 2, 4, NULL),
(182, '2024-05-13 19:12:13', 4, 5, NULL),
(183, '2024-05-13 19:12:13', 2, 5, NULL),
(184, '2024-05-13 19:12:14', 8, 10, NULL),
(185, '2024-05-13 19:12:15', 4, 5, NULL),
(186, '2024-05-13 19:12:15', 5, 7, NULL),
(187, '2024-05-13 19:12:16', 5, 7, NULL),
(188, '2024-05-13 19:12:16', 3, 2, NULL),
(189, '2024-05-13 19:12:17', 7, 5, NULL),
(190, '2024-05-13 19:12:19', 3, 2, NULL),
(191, '2024-05-13 19:12:20', 4, 5, NULL),
(192, '2024-05-13 19:12:21', 7, 5, NULL),
(193, '2024-05-13 19:12:22', 7, 5, NULL),
(194, '2024-05-13 19:12:23', 5, 6, NULL),
(195, '2024-05-13 19:12:23', 5, 7, NULL),
(196, '2024-05-13 19:12:24', 7, 5, NULL),
(197, '2024-05-13 19:12:24', 3, 2, NULL),
(198, '2024-05-13 19:12:25', 5, 7, NULL),
(199, '2024-05-13 19:12:26', 5, 7, NULL),
(200, '2024-05-13 19:12:26', 2, 4, NULL),
(201, '2024-05-13 19:12:27', 5, 7, NULL),
(202, '2024-05-13 19:12:28', 3, 2, NULL),
(203, '2024-05-13 19:12:29', 2, 4, NULL),
(204, '2024-05-13 19:12:30', 7, 5, NULL),
(205, '2024-05-13 19:12:30', 6, 8, NULL),
(206, '2024-05-13 19:12:31', 7, 5, NULL),
(207, '2024-05-13 19:12:31', 3, 2, NULL),
(208, '2024-05-13 19:12:33', 8, 9, NULL),
(209, '2024-05-13 19:12:34', 5, 7, NULL),
(210, '2024-05-13 19:12:34', 2, 4, NULL),
(211, '2024-05-13 19:12:34', 4, 5, NULL),
(212, '2024-05-13 19:12:37', 4, 5, NULL),
(213, '2024-05-13 19:12:38', 7, 5, NULL),
(214, '2024-05-13 19:12:40', 7, 5, NULL),
(215, '2024-05-13 19:12:41', 7, 5, NULL),
(216, '2024-05-13 19:12:41', 2, 4, NULL),
(217, '2024-05-13 19:12:42', 7, 5, NULL),
(218, '2024-05-13 19:12:42', 2, 5, NULL),
(219, '2024-05-13 19:12:42', 4, 5, NULL),
(220, '2024-05-13 19:12:44', 5, 7, NULL),
(221, '2024-05-13 19:12:45', 5, 6, NULL),
(222, '2024-05-13 19:12:45', 9, 7, NULL),
(223, '2024-05-13 19:12:49', 7, 5, NULL),
(224, '2024-05-13 19:12:49', 4, 5, NULL),
(225, '2024-05-13 19:12:50', 5, 6, NULL),
(226, '2024-05-13 19:12:50', 3, 2, NULL),
(227, '2024-05-13 19:12:51', 3, 2, NULL),
(228, '2024-05-13 19:12:52', 5, 6, NULL),
(229, '2024-05-13 19:12:52', 5, 6, NULL),
(230, '2024-05-13 19:12:52', 6, 8, NULL),
(231, '2024-05-13 19:12:52', 5, 7, NULL),
(232, '2024-05-13 19:12:56', 8, 9, NULL),
(233, '2024-05-13 19:12:57', 6, 8, NULL),
(234, '2024-05-13 19:12:59', 6, 8, NULL),
(235, '2024-05-13 19:12:59', 7, 5, NULL),
(236, '2024-05-13 19:12:59', 6, 8, NULL),
(237, '2024-05-13 19:13:00', 7, 5, NULL),
(238, '2024-05-13 19:13:00', 2, 4, NULL),
(239, '2024-05-13 19:13:01', 2, 4, NULL),
(240, '2024-05-13 19:13:02', 3, 2, NULL),
(241, '2024-05-13 19:13:03', 5, 7, NULL),
(242, '2024-05-13 19:13:07', 7, 5, NULL),
(243, '2024-05-13 19:13:08', 9, 7, NULL),
(244, '2024-05-13 19:13:09', 5, 6, NULL),
(245, '2024-05-13 19:13:09', 4, 5, NULL),
(246, '2024-05-13 19:13:10', 4, 5, NULL),
(247, '2024-05-13 19:13:12', 8, 10, NULL),
(248, '2024-05-13 19:13:12', 5, 7, NULL),
(249, '2024-05-13 19:13:13', 2, 4, NULL),
(250, '2024-05-13 19:13:13', 5, 7, NULL),
(251, '2024-05-13 19:13:14', 8, 10, NULL),
(252, '2024-05-13 19:13:16', 6, 8, NULL),
(253, '2024-05-13 19:13:19', 7, 5, NULL),
(254, '2024-05-13 19:13:21', 4, 5, NULL),
(255, '2024-05-13 19:13:22', 5, 7, NULL),
(256, '2024-05-13 19:13:28', 7, 5, NULL),
(257, '2024-05-13 19:13:29', 7, 5, NULL),
(258, '2024-05-13 19:13:31', 5, 6, NULL),
(259, '2024-05-13 19:13:31', 8, 10, NULL),
(260, '2024-05-13 19:13:37', 7, 5, NULL),
(261, '2024-05-13 19:13:38', 6, 8, NULL),
(262, '2024-05-13 19:13:39', 5, 6, NULL),
(263, '2024-05-13 19:13:42', 8, 9, NULL),
(264, '2024-05-13 19:13:50', 3, 2, NULL),
(265, '2024-05-13 19:13:54', 9, 7, NULL),
(266, '2024-05-13 19:14:03', 2, 5, NULL),
(267, '2024-05-13 19:14:19', 3, 2, NULL),
(268, '2024-05-13 19:14:22', 3, 2, NULL),
(269, '2024-05-13 19:14:25', 1, 2, NULL),
(270, '2024-05-13 19:14:28', 1, 2, NULL),
(271, '2024-05-13 19:14:29', 2, 4, NULL),
(272, '2024-05-13 19:14:31', 3, 2, NULL),
(273, '2024-05-13 19:14:32', 2, 4, NULL),
(274, '2024-05-13 19:14:34', 1, 2, NULL),
(275, '2024-05-13 19:14:37', 4, 5, NULL),
(276, '2024-05-13 19:14:37', 3, 2, NULL),
(277, '2024-05-13 19:14:38', 2, 5, NULL),
(278, '2024-05-13 19:14:38', 2, 4, NULL),
(279, '2024-05-13 19:14:40', 4, 5, NULL),
(280, '2024-05-13 19:14:43', 1, 2, NULL),
(281, '2024-05-13 19:14:44', 2, 4, NULL),
(282, '2024-05-13 19:14:44', 2, 5, NULL),
(283, '2024-05-13 19:14:46', 4, 5, NULL),
(284, '2024-05-13 19:14:46', 3, 2, NULL),
(285, '2024-05-13 19:14:47', 2, 4, NULL),
(286, '2024-05-13 19:14:49', 5, 7, NULL),
(287, '2024-05-13 19:14:49', 1, 2, NULL),
(288, '2024-05-13 19:14:50', 3, 2, NULL),
(289, '2024-05-13 19:14:50', 5, 6, NULL),
(290, '2024-05-13 19:14:51', 3, 2, NULL),
(291, '2024-05-13 19:14:52', 4, 5, NULL),
(292, '2024-05-13 19:14:52', 3, 2, NULL),
(293, '2024-05-13 19:14:54', 5, 6, NULL),
(294, '2024-05-13 19:14:55', 4, 5, NULL),
(295, '2024-05-13 19:14:55', 1, 2, NULL),
(296, '2024-05-13 19:14:56', 2, 5, NULL),
(297, '2024-05-13 19:14:58', 5, 7, NULL),
(298, '2024-05-13 19:14:58', 1, 2, NULL),
(299, '2024-05-13 19:14:59', 2, 4, NULL),
(300, '2024-05-13 19:14:59', 2, 5, NULL),
(301, '2024-05-13 19:15:00', 2, 4, NULL),
(302, '2024-05-13 19:15:01', 3, 2, NULL),
(303, '2024-05-13 19:15:02', 5, 6, NULL),
(304, '2024-05-13 19:15:02', 5, 7, NULL),
(305, '2024-05-13 19:15:04', 2, 5, NULL),
(306, '2024-05-13 19:15:04', 7, 5, NULL),
(307, '2024-05-13 19:15:04', 3, 2, NULL),
(308, '2024-05-13 19:15:05', 2, 5, NULL),
(309, '2024-05-13 19:15:06', 5, 6, NULL),
(310, '2024-05-13 19:15:07', 4, 5, NULL),
(311, '2024-05-13 19:15:07', 1, 2, NULL),
(312, '2024-05-13 19:15:08', 4, 5, NULL),
(313, '2024-05-13 19:15:08', 2, 5, NULL),
(314, '2024-05-13 19:15:08', 2, 4, NULL),
(315, '2024-05-13 19:15:09', 6, 8, NULL),
(316, '2024-05-13 19:15:10', 5, 7, NULL),
(317, '2024-05-13 19:15:10', 3, 2, NULL),
(318, '2024-05-13 19:15:11', 2, 4, NULL),
(319, '2024-05-13 19:15:13', 6, 8, NULL),
(320, '2024-05-13 19:15:13', 7, 5, NULL),
(321, '2024-05-13 19:15:13', 1, 2, NULL),
(322, '2024-05-13 19:15:14', 5, 6, NULL),
(323, '2024-05-13 19:15:14', 5, 6, NULL),
(324, '2024-05-13 19:15:16', 8, 9, NULL),
(325, '2024-05-13 19:15:16', 4, 5, NULL),
(326, '2024-05-13 19:15:16', 3, 2, NULL),
(327, '2024-05-13 19:15:17', 7, 5, NULL),
(328, '2024-05-13 19:15:17', 2, 5, NULL),
(329, '2024-05-13 19:15:18', 5, 6, NULL),
(330, '2024-05-13 19:15:18', 3, 2, NULL),
(331, '2024-05-13 19:15:19', 4, 5, NULL),
(332, '2024-05-13 19:15:19', 3, 2, NULL),
(333, '2024-05-13 19:15:20', 5, 7, NULL),
(334, '2024-05-13 19:15:20', 2, 5, NULL),
(335, '2024-05-13 19:15:20', 2, 4, NULL),
(336, '2024-05-13 19:15:21', 6, 8, NULL),
(337, '2024-05-13 19:15:21', 3, 2, NULL),
(338, '2024-05-13 19:15:21', 6, 8, NULL),
(339, '2024-05-13 19:15:22', 3, 2, NULL),
(340, '2024-05-13 19:15:23', 5, 6, NULL),
(341, '2024-05-13 19:15:23', 5, 7, NULL),
(342, '2024-05-13 19:15:25', 7, 5, NULL),
(343, '2024-05-13 19:15:25', 1, 2, NULL),
(344, '2024-05-13 19:15:26', 2, 5, NULL),
(345, '2024-05-13 19:15:26', 5, 6, NULL),
(346, '2024-05-13 19:15:27', 5, 6, NULL),
(347, '2024-05-13 19:15:28', 9, 7, NULL),
(348, '2024-05-13 19:15:28', 5, 7, NULL),
(349, '2024-05-13 19:15:28', 4, 5, NULL),
(350, '2024-05-13 19:15:28', 3, 2, NULL),
(351, '2024-05-13 19:15:29', 5, 6, NULL),
(352, '2024-05-13 19:15:29', 2, 5, NULL),
(353, '2024-05-13 19:15:30', 6, 8, NULL),
(354, '2024-05-13 19:15:31', 2, 4, NULL),
(355, '2024-05-13 19:15:31', 2, 5, NULL),
(356, '2024-05-13 19:15:31', 1, 2, NULL),
(357, '2024-05-13 19:15:32', 5, 7, NULL),
(358, '2024-05-13 19:15:32', 2, 5, NULL),
(359, '2024-05-13 19:15:32', 2, 4, NULL),
(360, '2024-05-13 19:15:34', 3, 2, NULL),
(361, '2024-05-13 19:15:35', 7, 5, NULL),
(362, '2024-05-13 19:15:37', 3, 2, NULL),
(363, '2024-05-13 19:15:38', 5, 7, NULL),
(364, '2024-05-13 19:15:38', 7, 5, NULL),
(365, '2024-05-13 19:15:38', 2, 5, NULL),
(366, '2024-05-13 19:15:39', 4, 5, NULL),
(367, '2024-05-13 19:15:39', 3, 2, NULL),
(368, '2024-05-13 19:15:40', 4, 5, NULL),
(369, '2024-05-13 19:15:40', 1, 2, NULL),
(370, '2024-05-13 19:15:41', 5, 7, NULL),
(371, '2024-05-13 19:15:41', 3, 2, NULL),
(372, '2024-05-13 19:15:41', 2, 5, NULL),
(373, '2024-05-13 19:15:43', 7, 5, NULL),
(374, '2024-05-13 19:15:43', 7, 5, NULL),
(375, '2024-05-13 19:15:43', 1, 2, NULL),
(376, '2024-05-13 19:15:44', 3, 2, NULL),
(377, '2024-05-13 19:15:44', 2, 5, NULL),
(378, '2024-05-13 19:15:45', 3, 2, NULL),
(379, '2024-05-13 19:15:46', 5, 7, 40),
(380, '2024-05-13 19:15:47', 7, 5, 40),
(381, '2024-05-13 19:15:47', 2, 5, 40),
(382, '2024-05-13 19:15:48', 5, 6, 40),
(383, '2024-05-13 19:15:50', 2, 5, 40),
(384, '2024-05-13 19:15:51', 5, 6, 40),
(385, '2024-05-13 19:15:52', 3, 2, 40),
(386, '2024-05-13 19:15:52', 2, 5, 40),
(387, '2024-05-13 19:15:52', 1, 2, 40),
(388, '2024-05-13 19:15:53', 7, 5, NULL),
(389, '2024-05-13 19:15:53', 3, 2, NULL),
(390, '2024-05-13 19:15:53', 2, 5, NULL),
(391, '2024-05-13 19:15:53', 2, 4, NULL),
(392, '2024-05-13 19:15:54', 2, 4, NULL),
(393, '2024-05-13 19:15:54', 2, 5, NULL),
(394, '2024-05-13 19:15:54', 5, 6, NULL),
(395, '2024-05-13 19:15:55', 5, 7, NULL),
(396, '2024-05-13 19:15:55', 2, 4, NULL),
(397, '2024-05-13 19:15:55', 1, 2, NULL),
(398, '2024-05-13 19:15:56', 3, 2, NULL),
(399, '2024-05-13 19:15:56', 5, 7, NULL),
(400, '2024-05-13 19:15:56', 7, 5, NULL),
(401, '2024-05-13 19:15:57', 5, 7, NULL),
(402, '2024-05-13 19:15:57', 5, 6, NULL),
(403, '2024-05-13 19:15:59', 5, 7, NULL),
(404, '2024-05-13 19:16:00', 3, 2, NULL),
(405, '2024-05-13 19:16:01', 7, 5, NULL),
(406, '2024-05-13 19:16:01', 4, 5, NULL),
(407, '2024-05-13 19:16:01', 3, 2, NULL),
(408, '2024-05-13 19:16:02', 2, 4, NULL),
(409, '2024-05-13 19:16:02', 4, 5, NULL),
(410, '2024-05-13 19:16:02', 2, 4, NULL),
(411, '2024-05-13 19:16:03', 4, 5, NULL),
(412, '2024-05-13 19:16:03', 3, 2, NULL),
(413, '2024-05-13 19:16:03', 5, 6, NULL),
(414, '2024-05-13 19:16:04', 6, 8, NULL),
(415, '2024-05-13 19:16:04', 1, 2, NULL),
(416, '2024-05-13 19:16:05', 5, 7, NULL),
(417, '2024-05-13 19:16:06', 2, 4, NULL),
(418, '2024-05-13 19:16:06', 2, 5, NULL),
(419, '2024-05-13 19:16:07', 8, 9, NULL),
(420, '2024-05-13 19:16:07', 1, 2, NULL),
(421, '2024-05-13 19:16:08', 2, 5, NULL),
(422, '2024-05-13 19:16:10', 4, 5, NULL),
(423, '2024-05-13 19:16:10', 7, 5, NULL),
(424, '2024-05-13 19:16:10', 2, 4, NULL),
(425, '2024-05-13 19:16:10', 4, 5, NULL),
(426, '2024-05-13 19:16:10', 3, 2, NULL),
(427, '2024-05-13 19:16:11', 7, 5, NULL),
(428, '2024-05-13 19:16:11', 5, 6, NULL),
(429, '2024-05-13 19:16:11', 5, 7, NULL),
(430, '2024-05-13 19:16:12', 7, 5, NULL),
(431, '2024-05-13 19:16:13', 5, 7, NULL),
(432, '2024-05-13 19:16:13', 1, 2, NULL),
(433, '2024-05-13 19:16:14', 3, 2, NULL),
(434, '2024-05-13 19:16:14', 4, 5, NULL),
(435, '2024-05-13 19:16:14', 5, 7, NULL),
(436, '2024-05-13 19:16:14', 7, 5, NULL),
(437, '2024-05-13 19:16:14', 2, 5, NULL),
(438, '2024-05-13 19:16:16', 3, 2, NULL),
(439, '2024-05-13 19:16:16', 2, 5, NULL),
(440, '2024-05-13 19:16:16', 3, 2, NULL),
(441, '2024-05-13 19:16:17', 5, 7, NULL),
(442, '2024-05-13 19:16:17', 2, 5, NULL),
(443, '2024-05-13 19:16:18', 4, 5, NULL),
(444, '2024-05-13 19:16:19', 9, 7, NULL),
(445, '2024-05-13 19:16:19', 3, 2, NULL),
(446, '2024-05-13 19:16:19', 5, 7, NULL),
(447, '2024-05-13 19:16:19', 1, 2, NULL),
(448, '2024-05-13 19:16:20', 5, 6, NULL),
(449, '2024-05-13 19:16:20', 7, 5, NULL),
(450, '2024-05-13 19:16:20', 5, 6, NULL),
(451, '2024-05-13 19:16:20', 2, 5, NULL),
(452, '2024-05-13 19:16:21', 5, 7, NULL),
(453, '2024-05-13 19:16:22', 1, 2, NULL),
(454, '2024-05-13 19:16:23', 5, 7, NULL),
(455, '2024-05-13 19:16:23', 2, 4, NULL),
(456, '2024-05-13 19:16:23', 2, 5, NULL),
(457, '2024-05-13 19:16:24', 2, 4, NULL),
(458, '2024-05-13 19:16:24', 5, 6, NULL),
(459, '2024-05-13 19:16:24', 5, 6, NULL),
(460, '2024-05-13 19:16:25', 3, 2, NULL),
(461, '2024-05-13 19:16:25', 3, 2, NULL),
(462, '2024-05-13 19:16:26', 2, 4, NULL),
(463, '2024-05-13 19:16:26', 7, 5, NULL),
(464, '2024-05-13 19:16:26', 2, 4, NULL),
(465, '2024-05-13 19:16:27', 5, 6, NULL),
(466, '2024-05-13 19:16:28', 7, 5, NULL),
(467, '2024-05-13 19:16:28', 3, 2, NULL),
(468, '2024-05-13 19:16:29', 7, 5, NULL),
(469, '2024-05-13 19:16:29', 2, 4, NULL),
(470, '2024-05-13 19:16:29', 5, 7, NULL),
(471, '2024-05-13 19:16:30', 5, 6, NULL),
(472, '2024-05-13 19:16:31', 6, 8, NULL),
(473, '2024-05-13 19:16:31', 5, 7, NULL),
(474, '2024-05-13 19:16:31', 1, 2, NULL),
(475, '2024-05-13 19:16:31', 4, 5, NULL),
(476, '2024-05-13 19:16:31', 6, 8, NULL),
(477, '2024-05-13 19:16:32', 4, 5, NULL),
(478, '2024-05-13 19:16:32', 7, 5, NULL),
(479, '2024-05-13 19:16:32', 2, 5, NULL),
(480, '2024-05-13 19:16:32', 2, 4, NULL),
(481, '2024-05-13 19:16:34', 7, 5, NULL),
(482, '2024-05-13 19:16:34', 4, 5, NULL),
(483, '2024-05-13 19:16:34', 7, 5, NULL),
(484, '2024-05-13 19:16:34', 4, 5, NULL),
(485, '2024-05-13 19:16:34', 5, 7, NULL),
(486, '2024-05-13 19:16:35', 5, 7, NULL),
(487, '2024-05-13 19:16:36', 7, 5, NULL),
(488, '2024-05-13 19:16:36', 3, 2, NULL),
(489, '2024-05-13 19:16:37', 6, 8, NULL),
(490, '2024-05-13 19:16:37', 5, 7, NULL),
(491, '2024-05-13 19:16:37', 5, 7, NULL),
(492, '2024-05-13 19:16:37', 4, 5, NULL),
(493, '2024-05-13 19:16:37', 1, 2, NULL),
(494, '2024-05-13 19:16:38', 2, 5, NULL),
(495, '2024-05-13 19:16:38', 7, 5, NULL),
(496, '2024-05-13 19:16:38', 2, 5, NULL),
(497, '2024-05-13 19:16:38', 2, 4, NULL),
(498, '2024-05-13 19:16:39', 5, 6, NULL),
(499, '2024-05-13 19:16:40', 4, 5, NULL),
(500, '2024-05-13 19:16:40', 1, 2, NULL),
(501, '2024-05-13 19:16:41', 2, 4, NULL),
(502, '2024-05-13 19:16:42', 5, 6, NULL),
(503, '2024-05-13 19:16:43', 3, 2, NULL),
(504, '2024-05-13 19:16:44', 5, 6, NULL),
(505, '2024-05-13 19:16:44', 7, 5, NULL),
(506, '2024-05-13 19:16:44', 5, 6, NULL),
(507, '2024-05-13 19:16:45', 3, 2, NULL),
(508, '2024-05-13 19:16:46', 6, 8, NULL),
(509, '2024-05-13 19:16:46', 7, 5, NULL),
(510, '2024-05-13 19:16:46', 5, 6, NULL),
(511, '2024-05-13 19:16:46', 4, 5, NULL),
(512, '2024-05-13 19:16:47', 5, 7, NULL),
(513, '2024-05-13 19:16:48', 5, 6, NULL),
(514, '2024-05-13 19:16:48', 5, 6, NULL),
(515, '2024-05-13 19:16:48', 5, 6, NULL),
(516, '2024-05-13 19:16:49', 5, 7, NULL),
(517, '2024-05-13 19:16:49', 2, 5, NULL),
(518, '2024-05-13 19:16:49', 4, 5, NULL),
(519, '2024-05-13 19:16:49', 7, 5, NULL),
(520, '2024-05-13 19:16:49', 3, 2, NULL),
(521, '2024-05-13 19:16:50', 7, 5, NULL),
(522, '2024-05-13 19:16:50', 3, 2, NULL),
(523, '2024-05-13 19:16:50', 2, 5, NULL),
(524, '2024-05-13 19:16:51', 6, 8, NULL),
(525, '2024-05-13 19:16:52', 8, 10, NULL),
(526, '2024-05-13 19:16:52', 7, 5, NULL),
(527, '2024-05-13 19:16:52', 7, 5, NULL),
(528, '2024-05-13 19:16:52', 5, 7, NULL),
(529, '2024-05-13 19:16:52', 5, 7, NULL),
(530, '2024-05-13 19:16:52', 1, 2, NULL),
(531, '2024-05-13 19:16:53', 6, 8, NULL),
(532, '2024-05-13 19:16:53', 3, 2, NULL),
(533, '2024-05-13 19:16:53', 5, 7, NULL),
(534, '2024-05-13 19:16:53', 2, 5, NULL),
(535, '2024-05-13 19:16:54', 8, 9, NULL),
(536, '2024-05-13 19:16:55', 6, 8, NULL),
(537, '2024-05-13 19:16:55', 5, 7, NULL),
(538, '2024-05-13 19:16:55', 6, 8, NULL),
(539, '2024-05-13 19:16:55', 3, 2, NULL),
(540, '2024-05-13 19:16:56', 5, 6, NULL),
(541, '2024-05-13 19:16:56', 2, 5, NULL),
(542, '2024-05-13 19:16:59', 5, 6, NULL),
(543, '2024-05-13 19:17:00', 2, 4, NULL),
(544, '2024-05-13 19:17:01', 3, 2, NULL),
(545, '2024-05-13 19:17:02', 7, 5, NULL),
(546, '2024-05-13 19:17:02', 2, 5, NULL),
(547, '2024-05-13 19:17:02', 2, 4, NULL),
(548, '2024-05-13 19:17:03', 2, 4, NULL),
(549, '2024-05-13 19:17:03', 5, 6, NULL),
(550, '2024-05-13 19:17:04', 7, 5, NULL),
(551, '2024-05-13 19:17:04', 1, 2, NULL),
(552, '2024-05-13 19:17:05', 3, 2, NULL),
(553, '2024-05-13 19:17:06', 9, 7, NULL),
(554, '2024-05-13 19:17:06', 6, 8, NULL),
(555, '2024-05-13 19:17:06', 5, 6, NULL),
(556, '2024-05-13 19:17:07', 7, 5, NULL),
(557, '2024-05-13 19:17:07', 7, 5, NULL),
(558, '2024-05-13 19:17:07', 3, 2, NULL),
(559, '2024-05-13 19:17:08', 4, 5, NULL),
(560, '2024-05-13 19:17:08', 7, 5, NULL),
(561, '2024-05-13 19:17:08', 2, 5, NULL),
(562, '2024-05-13 19:17:10', 7, 5, NULL),
(563, '2024-05-13 19:17:10', 8, 10, NULL),
(564, '2024-05-13 19:17:10', 5, 7, NULL),
(565, '2024-05-13 19:17:10', 4, 5, NULL),
(566, '2024-05-13 19:17:10', 1, 2, NULL),
(567, '2024-05-13 19:17:11', 5, 7, NULL),
(568, '2024-05-13 19:17:11', 4, 5, NULL),
(569, '2024-05-13 19:17:12', 5, 6, NULL),
(570, '2024-05-13 19:17:12', 5, 6, NULL),
(571, '2024-05-13 19:17:13', 5, 7, NULL),
(572, '2024-05-13 19:17:14', 2, 5, NULL),
(573, '2024-05-13 19:17:15', 2, 4, NULL),
(574, '2024-05-13 19:17:16', 1, 2, NULL),
(575, '2024-05-13 19:17:17', 2, 5, NULL),
(576, '2024-05-13 19:17:17', 2, 4, NULL),
(577, '2024-05-13 19:17:18', 5, 6, NULL),
(578, '2024-05-13 19:17:19', 6, 8, NULL),
(579, '2024-05-13 19:17:19', 6, 8, NULL),
(580, '2024-05-13 19:17:19', 1, 2, NULL),
(581, '2024-05-13 19:17:20', 3, 2, NULL),
(582, '2024-05-13 19:17:20', 5, 7, NULL),
(583, '2024-05-13 19:17:21', 7, 5, NULL),
(584, '2024-05-13 19:17:21', 5, 6, NULL),
(585, '2024-05-13 19:17:21', 8, 10, NULL),
(586, '2024-05-13 19:17:21', 3, 2, NULL),
(587, '2024-05-13 19:17:22', 8, 9, NULL),
(588, '2024-05-13 19:17:22', 1, 2, NULL),
(589, '2024-05-13 19:17:23', 3, 2, NULL),
(590, '2024-05-13 19:17:23', 2, 5, NULL),
(591, '2024-05-13 19:17:24', 5, 6, NULL),
(592, '2024-05-13 19:17:25', 7, 5, NULL),
(593, '2024-05-13 19:17:25', 4, 5, NULL),
(594, '2024-05-13 19:17:25', 3, 2, NULL),
(595, '2024-05-13 19:17:26', 7, 5, NULL),
(596, '2024-05-13 19:17:28', 7, 5, NULL),
(597, '2024-05-13 19:17:28', 5, 7, NULL),
(598, '2024-05-13 19:17:28', 6, 8, NULL),
(599, '2024-05-13 19:17:28', 1, 2, NULL),
(600, '2024-05-13 19:17:29', 2, 5, NULL),
(601, '2024-05-13 19:17:29', 2, 4, NULL),
(602, '2024-05-13 19:17:31', 1, 2, NULL),
(603, '2024-05-13 19:17:33', 2, 5, NULL),
(604, '2024-05-13 19:17:33', 2, 4, NULL),
(605, '2024-05-13 19:17:33', 5, 6, NULL),
(606, '2024-05-13 19:17:34', 9, 7, NULL),
(607, '2024-05-13 19:17:34', 2, 5, NULL),
(608, '2024-05-13 19:17:34', 3, 2, NULL),
(609, '2024-05-13 19:17:35', 7, 5, NULL),
(610, '2024-05-13 19:17:35', 5, 6, NULL),
(611, '2024-05-13 19:17:35', 2, 5, NULL),
(612, '2024-05-13 19:17:37', 4, 5, NULL),
(613, '2024-05-13 19:17:37', 1, 2, NULL),
(614, '2024-05-13 19:17:38', 5, 7, NULL),
(615, '2024-05-13 19:17:38', 5, 7, NULL),
(616, '2024-05-13 19:17:38', 2, 5, NULL),
(617, '2024-05-13 19:17:38', 2, 4, NULL),
(618, '2024-05-13 19:17:40', 5, 7, NULL),
(619, '2024-05-13 19:17:40', 1, 2, NULL),
(620, '2024-05-13 19:17:41', 4, 5, NULL),
(621, '2024-05-13 19:17:42', 3, 2, NULL),
(622, '2024-05-13 19:17:43', 7, 5, NULL),
(623, '2024-05-13 19:17:43', 3, 2, NULL),
(624, '2024-05-13 19:17:44', 5, 6, NULL),
(625, '2024-05-13 19:17:44', 2, 5, NULL),
(626, '2024-05-13 19:17:44', 2, 4, NULL),
(627, '2024-05-13 19:17:46', 5, 7, NULL),
(628, '2024-05-13 19:17:46', 3, 2, NULL),
(629, '2024-05-13 19:17:46', 4, 5, NULL),
(630, '2024-05-13 19:17:46', 3, 2, NULL),
(631, '2024-05-13 19:17:48', 5, 6, NULL),
(632, '2024-05-13 19:17:49', 7, 5, NULL),
(633, '2024-05-13 19:17:49', 3, 2, NULL),
(634, '2024-05-13 19:17:50', 2, 5, NULL),
(635, '2024-05-13 19:17:50', 2, 4, NULL),
(636, '2024-05-13 19:17:51', 6, 8, NULL),
(637, '2024-05-13 19:17:51', 5, 6, NULL),
(638, '2024-05-13 19:17:52', 2, 4, NULL),
(639, '2024-05-13 19:17:52', 4, 5, NULL),
(640, '2024-05-13 19:17:52', 1, 2, NULL),
(641, '2024-05-13 19:17:53', 7, 5, NULL),
(642, '2024-05-13 19:17:53', 7, 5, 41),
(643, '2024-05-13 19:17:53', 5, 7, 41),
(644, '2024-05-13 19:17:53', 2, 4, 41),
(645, '2024-05-13 19:17:54', 5, 6, 41),
(646, '2024-05-13 19:17:55', 7, 5, 41),
(647, '2024-05-13 19:17:55', 1, 2, 41),
(648, '2024-05-13 19:17:56', 2, 4, NULL),
(649, '2024-05-13 19:17:56', 5, 6, NULL),
(650, '2024-05-13 19:17:58', 6, 8, NULL),
(651, '2024-05-13 19:17:58', 4, 5, NULL),
(652, '2024-05-13 19:17:58', 3, 2, NULL),
(653, '2024-05-13 19:17:59', 5, 6, NULL),
(654, '2024-05-13 19:17:59', 2, 5, NULL),
(655, '2024-05-13 19:18:00', 4, 5, NULL),
(656, '2024-05-13 19:18:01', 7, 5, NULL),
(657, '2024-05-13 19:18:01', 8, 9, NULL),
(658, '2024-05-13 19:18:01', 4, 5, NULL),
(659, '2024-05-13 19:18:02', 5, 6, NULL),
(660, '2024-05-13 19:18:02', 5, 7, NULL),
(661, '2024-05-13 19:18:02', 2, 5, NULL),
(662, '2024-05-13 19:18:02', 2, 4, NULL),
(663, '2024-05-13 19:18:04', 5, 7, NULL),
(664, '2024-05-13 19:18:04', 4, 5, NULL),
(665, '2024-05-13 19:18:04', 3, 2, NULL),
(666, '2024-05-13 19:18:05', 5, 6, NULL),
(667, '2024-05-13 19:18:06', 3, 2, NULL),
(668, '2024-05-13 19:18:06', 3, 2, NULL),
(669, '2024-05-13 19:18:07', 3, 2, NULL),
(670, '2024-05-13 19:18:08', 5, 6, NULL),
(671, '2024-05-13 19:18:08', 7, 5, NULL),
(672, '2024-05-13 19:18:08', 2, 4, NULL),
(673, '2024-05-13 19:18:08', 2, 5, NULL),
(674, '2024-05-13 19:18:10', 4, 5, NULL),
(675, '2024-05-13 19:18:10', 1, 2, NULL),
(676, '2024-05-13 19:18:11', 5, 7, NULL),
(677, '2024-05-13 19:18:11', 5, 6, NULL),
(678, '2024-05-13 19:18:12', 6, 8, NULL),
(679, '2024-05-13 19:18:13', 9, 7, NULL),
(680, '2024-05-13 19:18:13', 3, 2, NULL),
(681, '2024-05-13 19:18:13', 1, 2, NULL),
(682, '2024-05-13 19:18:14', 5, 6, NULL),
(683, '2024-05-13 19:18:15', 3, 2, NULL),
(684, '2024-05-13 19:18:16', 4, 5, NULL),
(685, '2024-05-13 19:18:16', 3, 2, NULL),
(686, '2024-05-13 19:18:17', 7, 5, NULL),
(687, '2024-05-13 19:18:17', 2, 5, NULL),
(688, '2024-05-13 19:18:18', 5, 6, NULL);

--
-- Triggers `medicoespassagem`
--
DROP TRIGGER IF EXISTS `MedicoesPassagemInsertAfter`;
DELIMITER $$
CREATE TRIGGER `MedicoesPassagemInsertAfter` AFTER INSERT ON `medicoespassagem` FOR EACH ROW BEGIN

	IF new.IDExperiencia IS NOT NULL THEN
    	CALL AtualizarNumRatosSala(new.SalaOrigem, new.SalaDestino, new.IDExperiencia);
    END IF;

END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `MedicoesPassagemInsertBefore`;
DELIMITER $$
CREATE TRIGGER `MedicoesPassagemInsertBefore` BEFORE INSERT ON `medicoespassagem` FOR EACH ROW BEGIN

	DECLARE idExperiencia INT;
    CALL ObterExperienciaADecorrer(idExperiencia);
    
    SET new.IDExperiencia = idExperiencia;

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `medicoessala`
--

DROP TABLE IF EXISTS `medicoessala`;
CREATE TABLE IF NOT EXISTS `medicoessala` (
  `IDMedição` int(11) NOT NULL AUTO_INCREMENT,
  `IDExperiencia` int(11) DEFAULT NULL,
  `NúmeroRatosFinal` int(11) NOT NULL,
  `Sala` int(11) NOT NULL,
  PRIMARY KEY (`IDMedição`),
  KEY `ExpSalaFK` (`IDExperiencia`)
) ENGINE=InnoDB AUTO_INCREMENT=138 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `medicoessala`
--

INSERT INTO `medicoessala` (`IDMedição`, `IDExperiencia`, `NúmeroRatosFinal`, `Sala`) VALUES
(1, 24, 99, 1),
(2, 24, 1, 2),
(3, 24, 1, 3),
(4, 24, 0, 4),
(5, 24, 0, 5),
(6, 24, 0, 6),
(7, 24, 0, 7),
(8, 24, 0, 8),
(9, 24, 0, 9),
(10, 24, 0, 10),
(12, 25, 99, 1),
(13, 25, 1, 2),
(14, 25, 0, 3),
(15, 25, 0, 4),
(16, 25, 0, 5),
(17, 25, 0, 6),
(18, 25, 0, 7),
(19, 25, 0, 8),
(20, 25, 0, 9),
(21, 25, 0, 10),
(22, 26, 99, 1),
(23, 26, 1, 2),
(24, 26, 0, 3),
(25, 26, 0, 4),
(26, 26, 0, 5),
(27, 26, 0, 6),
(28, 26, 0, 7),
(29, 26, 0, 8),
(30, 26, 0, 9),
(31, 27, 99, 1),
(32, 27, 1, 2),
(33, 27, 0, 3),
(34, 27, 0, 4),
(35, 27, 0, 5),
(36, 27, 0, 6),
(37, 27, 0, 7),
(38, 27, 0, 8),
(39, 27, 0, 9),
(40, 28, 99, 1),
(41, 28, 1, 2),
(42, 28, 0, 3),
(43, 28, 0, 4),
(44, 28, 0, 5),
(45, 28, 0, 6),
(46, 28, 0, 7),
(47, 28, 0, 8),
(48, 28, 0, 9),
(88, 37, 99, 1),
(89, 37, 1, 2),
(90, 37, 0, 3),
(91, 37, 0, 4),
(92, 37, 0, 5),
(93, 37, 0, 6),
(94, 37, 0, 7),
(95, 37, 0, 8),
(96, 37, 0, 9),
(97, 37, 0, 10),
(98, 38, 99, 1),
(99, 38, 1, 2),
(100, 38, 0, 3),
(101, 38, 0, 4),
(102, 38, 0, 5),
(103, 38, 0, 6),
(104, 38, 0, 7),
(105, 38, 0, 8),
(106, 38, 0, 9),
(107, 38, 0, 10),
(108, 39, 99, 1),
(109, 39, 1, 2),
(110, 39, 0, 3),
(111, 39, 0, 4),
(112, 39, 0, 5),
(113, 39, 0, 6),
(114, 39, 0, 7),
(115, 39, 0, 8),
(116, 39, 0, 9),
(117, 39, 0, 10),
(118, 40, 99, 1),
(119, 40, 1, 2),
(120, 40, 0, 3),
(121, 40, 0, 4),
(122, 40, 0, 5),
(123, 40, 0, 6),
(124, 40, 0, 7),
(125, 40, 0, 8),
(126, 40, 0, 9),
(127, 40, 0, 10),
(128, 41, 100, 1),
(129, 41, 0, 2),
(130, 41, 0, 3),
(131, 41, 0, 4),
(132, 41, 0, 5),
(133, 41, 0, 6),
(134, 41, 0, 7),
(135, 41, 0, 8),
(136, 41, 0, 9),
(137, 41, 0, 10);

--
-- Triggers `medicoessala`
--
DROP TRIGGER IF EXISTS `MedicoesSalaUpdateAfter`;
DELIMITER $$
CREATE TRIGGER `MedicoesSalaUpdateAfter` AFTER UPDATE ON `medicoessala` FOR EACH ROW BEGIN

	DECLARE limiteRatos INT;
    DECLARE expACorrer INT;
	SELECT exp.LimiteRatosSala INTO limiteRatos FROM experiencia exp WHERE exp.IDExperiencia = NEW.IDExperiencia LIMIT 1;
    SELECT e.IDExperiencia INTO expACorrer FROM v_expadecorrer e WHERE e.IDExperiencia = NEW.IDExperiencia LIMIT 1;
    
    IF expACorrer IS NOT NULL THEN
        IF NEW.NúmeroRatosFinal = limiteRatos THEN
            CAll InserirAlerta(NEW.Sala,NULL,NULL, 'Capacidade da sala', 'Limite de ratos atingido!');
        ELSEIF NEW.NúmeroRatosFinal > limiteRatos THEN
            CAll InserirAlerta(NEW.Sala,NULL,NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!');
            CAll ComecarTerminarExperienca(NEW.IDExperiencia);
        END IF;
    END IF;

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `medicoestemperatura`
--

DROP TABLE IF EXISTS `medicoestemperatura`;
CREATE TABLE IF NOT EXISTS `medicoestemperatura` (
  `IDMedição` int(11) NOT NULL AUTO_INCREMENT,
  `DataHora` datetime DEFAULT NULL,
  `Leitura` decimal(4,2) NOT NULL,
  `Sensor` int(11) NOT NULL,
  `IDExperiencia` int(11) DEFAULT NULL,
  PRIMARY KEY (`IDMedição`),
  KEY `ExpTemperatura` (`IDExperiencia`),
  KEY `Sensor` (`Sensor`)
) ENGINE=InnoDB AUTO_INCREMENT=1175 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `medicoestemperatura`
--

INSERT INTO `medicoestemperatura` (`IDMedição`, `DataHora`, `Leitura`, `Sensor`, `IDExperiencia`) VALUES
(1, '2024-05-13 19:11:54', '-42.00', 2, NULL),
(2, '2024-05-13 19:11:54', '-41.00', 3, NULL),
(3, '2024-05-13 19:11:55', '-41.00', 2, NULL),
(4, '2024-05-13 19:11:55', '-40.00', 3, NULL),
(5, '2024-05-13 19:11:56', '-40.00', 2, NULL),
(6, '2024-05-13 19:11:56', '-39.00', 3, NULL),
(7, '2024-05-13 19:11:57', '-39.00', 2, NULL),
(8, '2024-05-13 19:11:57', '-38.00', 3, NULL),
(9, '2024-05-13 19:11:58', '-38.00', 2, NULL),
(10, '2024-05-13 19:11:58', '-37.00', 3, NULL),
(11, '2024-05-13 19:11:59', '-37.00', 2, NULL),
(12, '2024-05-13 19:11:59', '-36.00', 3, NULL),
(13, '2024-05-13 19:12:00', '-36.00', 2, NULL),
(14, '2024-05-13 19:12:00', '-35.00', 3, NULL),
(15, '2024-05-13 19:12:01', '-35.00', 2, NULL),
(16, '2024-05-13 19:12:01', '-34.00', 3, NULL),
(17, '2024-05-13 19:12:02', '-34.00', 2, NULL),
(18, '2024-05-13 19:12:02', '-33.00', 3, NULL),
(19, '2024-05-13 19:12:03', '-33.00', 2, NULL),
(20, '2024-05-13 19:12:03', '-32.00', 3, NULL),
(21, '2024-05-13 19:12:04', '-32.00', 2, NULL),
(22, '2024-05-13 19:12:04', '-31.00', 3, NULL),
(23, '2024-05-13 19:12:05', '-30.00', 3, NULL),
(24, '2024-05-13 19:12:05', '-31.00', 2, NULL),
(25, '2024-05-13 19:12:06', '-29.00', 3, NULL),
(26, '2024-05-13 19:12:06', '-30.00', 2, NULL),
(27, '2024-05-13 19:12:07', '-29.00', 2, NULL),
(28, '2024-05-13 19:12:07', '-28.00', 3, NULL),
(29, '2024-05-13 19:12:08', '-28.00', 2, NULL),
(30, '2024-05-13 19:12:08', '-27.00', 3, NULL),
(31, '2024-05-13 19:12:09', '-27.00', 2, NULL),
(32, '2024-05-13 19:12:09', '-26.00', 3, NULL),
(33, '2024-05-13 19:12:10', '-26.00', 2, NULL),
(34, '2024-05-13 19:12:10', '-25.00', 3, NULL),
(35, '2024-05-13 19:12:11', '-25.00', 2, NULL),
(36, '2024-05-13 19:12:11', '-24.00', 3, NULL),
(37, '2024-05-13 19:12:12', '-24.00', 2, NULL),
(38, '2024-05-13 19:12:12', '-23.00', 3, NULL),
(39, '2024-05-13 19:12:13', '-23.00', 2, NULL),
(40, '2024-05-13 19:12:13', '-22.00', 3, NULL),
(41, '2024-05-13 19:12:14', '-22.00', 2, NULL),
(42, '2024-05-13 19:12:14', '-21.00', 3, NULL),
(43, '2024-05-13 19:12:15', '-21.00', 2, NULL),
(44, '2024-05-13 19:12:15', '-20.00', 3, NULL),
(45, '2024-05-13 19:12:16', '-20.00', 2, NULL),
(46, '2024-05-13 19:12:16', '-19.00', 3, NULL),
(47, '2024-05-13 19:12:17', '-19.00', 2, NULL),
(48, '2024-05-13 19:12:17', '-18.00', 3, NULL),
(49, '2024-05-13 19:12:18', '-18.00', 2, NULL),
(50, '2024-05-13 19:12:18', '-17.00', 3, NULL),
(51, '2024-05-13 19:12:19', '-17.00', 2, NULL),
(52, '2024-05-13 19:12:19', '-16.00', 3, NULL),
(53, '2024-05-13 19:12:20', '-16.00', 2, NULL),
(54, '2024-05-13 19:12:20', '-15.00', 3, NULL),
(55, '2024-05-13 19:12:21', '-15.00', 2, NULL),
(56, '2024-05-13 19:12:21', '-14.00', 3, NULL),
(57, '2024-05-13 19:12:22', '-14.00', 2, NULL),
(58, '2024-05-13 19:12:22', '-13.00', 3, NULL),
(59, '2024-05-13 19:12:23', '-13.00', 2, NULL),
(60, '2024-05-13 19:12:23', '-12.00', 3, NULL),
(61, '2024-05-13 19:12:24', '-12.00', 2, NULL),
(62, '2024-05-13 19:12:24', '-11.00', 3, NULL),
(63, '2024-05-13 19:12:25', '-11.00', 2, NULL),
(64, '2024-05-13 19:12:25', '-10.00', 3, NULL),
(65, '2024-05-13 19:12:26', '-10.00', 2, NULL),
(66, '2024-05-13 19:12:26', '-9.00', 3, NULL),
(67, '2024-05-13 19:12:27', '-9.00', 2, NULL),
(68, '2024-05-13 19:12:27', '-8.00', 3, NULL),
(69, '2024-05-13 19:12:28', '-8.00', 2, NULL),
(70, '2024-05-13 19:12:28', '-7.00', 3, NULL),
(71, '2024-05-13 19:12:29', '-7.00', 2, NULL),
(72, '2024-05-13 19:12:29', '-6.00', 3, NULL),
(73, '2024-05-13 19:12:30', '-6.00', 2, NULL),
(74, '2024-05-13 19:12:30', '-5.00', 3, NULL),
(75, '2024-05-13 19:12:32', '-5.00', 2, NULL),
(76, '2024-05-13 19:12:32', '-4.00', 3, NULL),
(77, '2024-05-13 19:12:33', '-4.00', 2, NULL),
(78, '2024-05-13 19:12:33', '-3.00', 3, NULL),
(79, '2024-05-13 19:12:34', '-3.00', 2, NULL),
(80, '2024-05-13 19:12:34', '-2.00', 3, NULL),
(81, '2024-05-13 19:12:35', '-2.00', 2, NULL),
(82, '2024-05-13 19:12:35', '-1.00', 3, NULL),
(83, '2024-05-13 19:12:36', '-1.00', 2, NULL),
(84, '2024-05-13 19:12:36', '0.00', 3, NULL),
(85, '2024-05-13 19:12:37', '0.00', 2, NULL),
(86, '2024-05-13 19:12:37', '1.00', 3, NULL),
(87, '2024-05-13 19:12:38', '1.00', 2, NULL),
(88, '2024-05-13 19:12:38', '2.00', 3, NULL),
(89, '2024-05-13 19:12:39', '2.00', 2, NULL),
(90, '2024-05-13 19:12:39', '3.00', 3, NULL),
(91, '2024-05-13 19:12:40', '3.00', 2, NULL),
(92, '2024-05-13 19:12:40', '4.00', 3, NULL),
(93, '2024-05-13 19:12:41', '4.00', 2, NULL),
(94, '2024-05-13 19:12:41', '5.00', 3, NULL),
(95, '2024-05-13 19:12:42', '5.00', 2, NULL),
(96, '2024-05-13 19:12:42', '6.00', 3, NULL),
(97, '2024-05-13 19:12:43', '6.00', 2, NULL),
(98, '2024-05-13 19:12:43', '7.00', 3, NULL),
(99, '2024-05-13 19:12:44', '7.00', 2, NULL),
(100, '2024-05-13 19:12:44', '8.00', 3, NULL),
(101, '2024-05-13 19:12:45', '8.00', 2, NULL),
(102, '2024-05-13 19:12:45', '9.00', 3, NULL),
(103, '2024-05-13 19:12:46', '9.00', 2, NULL),
(104, '2024-05-13 19:12:46', '10.00', 3, NULL),
(105, '2024-05-13 19:12:47', '10.00', 2, NULL),
(106, '2024-05-13 19:12:47', '11.00', 3, NULL),
(107, '2024-05-13 19:12:48', '11.00', 2, NULL),
(108, '2024-05-13 19:12:48', '12.00', 3, NULL),
(109, '2024-05-13 19:12:49', '12.00', 2, NULL),
(110, '2024-05-13 19:12:49', '13.00', 3, NULL),
(111, '2024-05-13 19:12:50', '13.00', 2, NULL),
(112, '2024-05-13 19:12:50', '14.00', 3, NULL),
(113, '2024-05-13 19:12:51', '14.00', 2, NULL),
(114, '2024-05-13 19:12:51', '15.00', 3, NULL),
(115, '2024-05-13 19:12:52', '15.00', 2, NULL),
(116, '2024-05-13 19:12:52', '16.00', 3, NULL),
(117, '2024-05-13 19:12:53', '16.00', 2, NULL),
(118, '2024-05-13 19:12:53', '17.00', 3, NULL),
(119, '2024-05-13 19:12:54', '17.00', 2, NULL),
(120, '2024-05-13 19:12:54', '18.00', 3, NULL),
(121, '2024-05-13 19:12:55', '18.00', 2, NULL),
(122, '2024-05-13 19:12:55', '19.00', 3, NULL),
(123, '2024-05-13 19:12:56', '19.00', 2, NULL),
(124, '2024-05-13 19:12:56', '20.00', 3, NULL),
(125, '2024-05-13 19:12:57', '20.00', 2, NULL),
(126, '2024-05-13 19:12:57', '21.00', 3, NULL),
(127, '2024-05-13 19:12:58', '21.00', 2, NULL),
(128, '2024-05-13 19:12:58', '22.00', 3, NULL),
(129, '2024-05-13 19:12:59', '22.00', 2, NULL),
(130, '2024-05-13 19:12:59', '23.00', 3, NULL),
(131, '2024-05-13 19:13:00', '23.00', 2, NULL),
(132, '2024-05-13 19:13:00', '24.00', 3, NULL),
(133, '2024-05-13 19:13:01', '24.00', 2, NULL),
(134, '2024-05-13 19:13:01', '25.00', 3, NULL),
(135, '2024-05-13 19:13:02', '25.00', 2, NULL),
(136, '2024-05-13 19:13:02', '26.00', 3, NULL),
(137, '2024-05-13 19:13:03', '26.00', 2, NULL),
(138, '2024-05-13 19:13:03', '27.00', 3, NULL),
(139, '2024-05-13 19:13:04', '27.00', 2, NULL),
(140, '2024-05-13 19:13:04', '28.00', 3, NULL),
(141, '2024-05-13 19:13:05', '28.00', 2, NULL),
(142, '2024-05-13 19:13:05', '29.00', 3, NULL),
(143, '2024-05-13 19:13:06', '29.00', 2, NULL),
(144, '2024-05-13 19:13:06', '30.00', 3, NULL),
(145, '2024-05-13 19:13:07', '30.00', 2, NULL),
(146, '2024-05-13 19:13:07', '31.00', 3, NULL),
(147, '2024-05-13 19:13:08', '31.00', 2, NULL),
(148, '2024-05-13 19:13:08', '32.00', 3, NULL),
(149, '2024-05-13 19:13:09', '32.00', 2, NULL),
(150, '2024-05-13 19:13:09', '33.00', 3, NULL),
(151, '2024-05-13 19:13:10', '33.00', 2, NULL),
(152, '2024-05-13 19:13:10', '34.00', 3, NULL),
(153, '2024-05-13 19:13:11', '34.00', 2, NULL),
(154, '2024-05-13 19:13:11', '35.00', 3, NULL),
(155, '2024-05-13 19:13:12', '35.00', 2, NULL),
(156, '2024-05-13 19:13:12', '36.00', 3, NULL),
(157, '2024-05-13 19:13:13', '36.00', 2, NULL),
(158, '2024-05-13 19:13:13', '37.00', 3, 39),
(159, '2024-05-13 19:13:14', '37.00', 2, 39),
(160, '2024-05-13 19:13:14', '38.00', 3, 39),
(161, '2024-05-13 19:13:15', '38.00', 2, 39),
(162, '2024-05-13 19:13:15', '39.00', 3, 39),
(163, '2024-05-13 19:13:16', '39.00', 2, 39),
(164, '2024-05-13 19:13:16', '40.00', 3, 39),
(165, '2024-05-13 19:13:17', '40.00', 2, 39),
(166, '2024-05-13 19:13:17', '41.00', 3, 39),
(167, '2024-05-13 19:13:18', '41.00', 2, 39),
(168, '2024-05-13 19:13:18', '42.00', 3, 39),
(169, '2024-05-13 19:13:19', '42.00', 2, 39),
(170, '2024-05-13 19:13:19', '43.00', 3, 39),
(171, '2024-05-13 19:13:20', '43.00', 2, 39),
(172, '2024-05-13 19:13:20', '44.00', 3, 39),
(173, '2024-05-13 19:13:21', '44.00', 2, 39),
(174, '2024-05-13 19:13:21', '45.00', 3, 39),
(175, '2024-05-13 19:13:22', '45.00', 2, 39),
(176, '2024-05-13 19:13:22', '46.00', 3, 39),
(177, '2024-05-13 19:13:23', '46.00', 2, 39),
(178, '2024-05-13 19:13:23', '47.00', 3, 39),
(179, '2024-05-13 19:13:24', '47.00', 2, 39),
(180, '2024-05-13 19:13:24', '48.00', 3, 39),
(181, '2024-05-13 19:13:25', '48.00', 2, 39),
(182, '2024-05-13 19:13:25', '49.00', 3, 39),
(183, '2024-05-13 19:13:26', '49.00', 2, 39),
(184, '2024-05-13 19:13:26', '50.00', 3, 39),
(185, '2024-05-13 19:13:39', '-37.00', 3, NULL),
(186, '2024-05-13 19:13:40', '-37.00', 2, NULL),
(187, '2024-05-13 19:13:40', '-36.00', 3, NULL),
(188, '2024-05-13 19:13:41', '-36.00', 2, NULL),
(189, '2024-05-13 19:13:41', '-35.00', 3, NULL),
(190, '2024-05-13 19:13:42', '-35.00', 2, NULL),
(191, '2024-05-13 19:13:42', '-34.00', 3, NULL),
(192, '2024-05-13 19:13:43', '-34.00', 2, NULL),
(193, '2024-05-13 19:13:43', '-33.00', 3, NULL),
(194, '2024-05-13 19:13:44', '-33.00', 2, NULL),
(195, '2024-05-13 19:13:44', '-32.00', 3, NULL),
(196, '2024-05-13 19:13:45', '-32.00', 2, NULL),
(197, '2024-05-13 19:13:45', '-31.00', 3, NULL),
(198, '2024-05-13 19:13:46', '-31.00', 2, NULL),
(199, '2024-05-13 19:13:46', '-30.00', 3, NULL),
(200, '2024-05-13 19:13:47', '-30.00', 2, NULL),
(201, '2024-05-13 19:13:47', '-29.00', 3, NULL),
(202, '2024-05-13 19:13:48', '-29.00', 2, NULL),
(203, '2024-05-13 19:13:48', '-28.00', 3, NULL),
(204, '2024-05-13 19:13:49', '-28.00', 2, NULL),
(205, '2024-05-13 19:13:49', '-27.00', 3, NULL),
(206, '2024-05-13 19:13:50', '-27.00', 2, NULL),
(207, '2024-05-13 19:13:50', '-26.00', 3, NULL),
(208, '2024-05-13 19:13:51', '-26.00', 2, NULL),
(209, '2024-05-13 19:13:51', '-25.00', 3, NULL),
(210, '2024-05-13 19:13:52', '-25.00', 2, NULL),
(211, '2024-05-13 19:13:52', '-24.00', 3, NULL),
(212, '2024-05-13 19:13:53', '-24.00', 2, NULL),
(213, '2024-05-13 19:13:53', '-23.00', 3, NULL),
(214, '2024-05-13 19:13:54', '-23.00', 2, NULL),
(215, '2024-05-13 19:13:54', '-22.00', 3, NULL),
(216, '2024-05-13 19:13:55', '-22.00', 2, NULL),
(217, '2024-05-13 19:13:55', '-21.00', 3, NULL),
(218, '2024-05-13 19:13:56', '-21.00', 2, NULL),
(219, '2024-05-13 19:13:56', '-20.00', 3, NULL),
(220, '2024-05-13 19:13:57', '-20.00', 2, NULL),
(221, '2024-05-13 19:13:57', '-19.00', 3, NULL),
(222, '2024-05-13 19:13:58', '-19.00', 2, NULL),
(223, '2024-05-13 19:13:58', '-18.00', 3, NULL),
(224, '2024-05-13 19:13:59', '-18.00', 2, NULL),
(225, '2024-05-13 19:13:59', '-17.00', 3, NULL),
(226, '2024-05-13 19:14:00', '-17.00', 2, NULL),
(227, '2024-05-13 19:14:00', '-16.00', 3, NULL),
(228, '2024-05-13 19:14:01', '-16.00', 2, NULL),
(229, '2024-05-13 19:14:01', '-15.00', 3, NULL),
(230, '2024-05-13 19:14:02', '-15.00', 2, NULL),
(231, '2024-05-13 19:14:02', '-14.00', 3, NULL),
(232, '2024-05-13 19:14:03', '-14.00', 2, NULL),
(233, '2024-05-13 19:14:03', '-13.00', 3, NULL),
(234, '2024-05-13 19:14:04', '-13.00', 2, NULL),
(235, '2024-05-13 19:14:04', '-12.00', 3, NULL),
(236, '2024-05-13 19:14:05', '-12.00', 2, NULL),
(237, '2024-05-13 19:14:05', '-11.00', 3, NULL),
(238, '2024-05-13 19:14:06', '-11.00', 2, NULL),
(239, '2024-05-13 19:14:06', '-10.00', 3, NULL),
(240, '2024-05-13 19:14:07', '-10.00', 2, NULL),
(241, '2024-05-13 19:14:07', '-9.00', 3, NULL),
(242, '2024-05-13 19:14:08', '-9.00', 2, NULL),
(243, '2024-05-13 19:14:08', '-8.00', 3, NULL),
(244, '2024-05-13 19:14:09', '-8.00', 2, NULL),
(245, '2024-05-13 19:14:09', '-7.00', 3, NULL),
(246, '2024-05-13 19:14:10', '-7.00', 2, NULL),
(247, '2024-05-13 19:14:10', '-6.00', 3, NULL),
(248, '2024-05-13 19:14:11', '-6.00', 2, NULL),
(249, '2024-05-13 19:14:11', '-5.00', 3, NULL),
(250, '2024-05-13 19:14:12', '-5.00', 2, NULL),
(251, '2024-05-13 19:14:12', '-4.00', 3, NULL),
(252, '2024-05-13 19:14:13', '-4.00', 2, NULL),
(253, '2024-05-13 19:14:13', '-3.00', 3, NULL),
(254, '2024-05-13 19:14:14', '-3.00', 2, NULL),
(255, '2024-05-13 19:14:14', '-2.00', 3, NULL),
(256, '2024-05-13 19:14:15', '-2.00', 2, NULL),
(257, '2024-05-13 19:14:15', '-1.00', 3, NULL),
(258, '2024-05-13 19:14:16', '-1.00', 2, NULL),
(259, '2024-05-13 19:14:16', '0.00', 3, NULL),
(260, '2024-05-13 19:14:17', '0.00', 2, NULL),
(261, '2024-05-13 19:14:17', '1.00', 3, NULL),
(262, '2024-05-13 19:14:18', '1.00', 2, NULL),
(263, '2024-05-13 19:14:18', '2.00', 3, NULL),
(264, '2024-05-13 19:14:19', '2.00', 2, NULL),
(265, '2024-05-13 19:14:19', '3.00', 3, NULL),
(266, '2024-05-13 19:14:20', '3.00', 2, NULL),
(267, '2024-05-13 19:14:20', '4.00', 3, NULL),
(268, '2024-05-13 19:14:21', '4.00', 2, NULL),
(269, '2024-05-13 19:14:22', '5.00', 3, NULL),
(270, '2024-05-13 19:14:23', '5.00', 2, NULL),
(271, '2024-05-13 19:14:23', '6.00', 3, NULL),
(272, '2024-05-13 19:14:24', '6.00', 2, NULL),
(273, '2024-05-13 19:14:24', '7.00', 3, NULL),
(274, '2024-05-13 19:14:25', '7.00', 2, NULL),
(275, '2024-05-13 19:14:25', '8.00', 3, NULL),
(276, '2024-05-13 19:14:26', '8.00', 2, NULL),
(277, '2024-05-13 19:14:26', '9.00', 3, NULL),
(278, '2024-05-13 19:14:27', '9.00', 2, NULL),
(279, '2024-05-13 19:14:27', '10.00', 3, NULL),
(280, '2024-05-13 19:14:28', '10.00', 2, NULL),
(281, '2024-05-13 19:14:28', '11.00', 3, NULL),
(282, '2024-05-13 19:14:29', '11.00', 2, NULL),
(283, '2024-05-13 19:14:29', '12.00', 3, NULL),
(284, '2024-05-13 19:14:30', '12.00', 2, NULL),
(285, '2024-05-13 19:14:30', '13.00', 3, NULL),
(286, '2024-05-13 19:14:31', '13.00', 2, NULL),
(287, '2024-05-13 19:14:31', '14.00', 3, NULL),
(288, '2024-05-13 19:14:32', '14.00', 2, NULL),
(289, '2024-05-13 19:14:32', '15.00', 3, NULL),
(290, '2024-05-13 19:14:33', '15.00', 2, NULL),
(291, '2024-05-13 19:14:33', '16.00', 3, NULL),
(292, '2024-05-13 19:14:34', '16.00', 2, NULL),
(293, '2024-05-13 19:14:34', '17.00', 3, NULL),
(294, '2024-05-13 19:14:35', '17.00', 2, NULL),
(295, '2024-05-13 19:14:35', '18.00', 3, NULL),
(296, '2024-05-13 19:14:36', '18.00', 2, NULL),
(297, '2024-05-13 19:14:36', '19.00', 3, NULL),
(298, '2024-05-13 19:14:37', '19.00', 2, NULL),
(299, '2024-05-13 19:14:37', '20.00', 3, NULL),
(300, '2024-05-13 19:14:38', '20.00', 2, NULL),
(301, '2024-05-13 19:14:38', '21.00', 3, NULL),
(302, '2024-05-13 19:14:39', '21.00', 2, NULL),
(303, '2024-05-13 19:14:39', '22.00', 3, NULL),
(304, '2024-05-13 19:14:40', '22.00', 2, NULL),
(305, '2024-05-13 19:14:40', '23.00', 3, NULL),
(306, '2024-05-13 19:14:41', '23.00', 2, NULL),
(307, '2024-05-13 19:14:41', '24.00', 3, NULL),
(308, '2024-05-13 19:14:42', '24.00', 2, NULL),
(309, '2024-05-13 19:14:42', '25.00', 3, NULL),
(310, '2024-05-13 19:14:43', '26.00', 3, NULL),
(311, '2024-05-13 19:14:43', '25.00', 2, NULL),
(312, '2024-05-13 19:14:44', '26.00', 2, NULL),
(313, '2024-05-13 19:14:44', '27.00', 3, NULL),
(314, '2024-05-13 19:14:45', '27.00', 2, NULL),
(315, '2024-05-13 19:14:45', '28.00', 3, NULL),
(316, '2024-05-13 19:14:46', '28.00', 2, NULL),
(317, '2024-05-13 19:14:46', '29.00', 3, NULL),
(318, '2024-05-13 19:14:47', '29.00', 2, NULL),
(319, '2024-05-13 19:14:47', '30.00', 3, NULL),
(320, '2024-05-13 19:14:48', '30.00', 2, NULL),
(321, '2024-05-13 19:14:48', '31.00', 3, NULL),
(322, '2024-05-13 19:14:49', '31.00', 2, NULL),
(323, '2024-05-13 19:14:49', '32.00', 3, NULL),
(324, '2024-05-13 19:14:50', '32.00', 2, NULL),
(325, '2024-05-13 19:14:50', '33.00', 3, NULL),
(326, '2024-05-13 19:14:51', '33.00', 2, NULL),
(327, '2024-05-13 19:14:51', '34.00', 3, NULL),
(328, '2024-05-13 19:14:52', '34.00', 2, NULL),
(329, '2024-05-13 19:14:52', '35.00', 3, NULL),
(330, '2024-05-13 19:14:53', '35.00', 2, NULL),
(331, '2024-05-13 19:14:53', '36.00', 3, NULL),
(332, '2024-05-13 19:14:54', '36.00', 2, NULL),
(333, '2024-05-13 19:14:54', '37.00', 3, NULL),
(334, '2024-05-13 19:14:55', '37.00', 2, NULL),
(335, '2024-05-13 19:14:55', '38.00', 3, NULL),
(336, '2024-05-13 19:14:56', '38.00', 2, NULL),
(337, '2024-05-13 19:14:56', '39.00', 3, NULL),
(338, '2024-05-13 19:14:57', '39.00', 2, NULL),
(339, '2024-05-13 19:14:57', '40.00', 3, NULL),
(340, '2024-05-13 19:14:58', '40.00', 2, NULL),
(341, '2024-05-13 19:14:58', '41.00', 3, NULL),
(342, '2024-05-13 19:14:59', '41.00', 2, NULL),
(343, '2024-05-13 19:14:59', '42.00', 3, NULL),
(344, '2024-05-13 19:15:00', '42.00', 2, NULL),
(345, '2024-05-13 19:15:00', '43.00', 3, NULL),
(346, '2024-05-13 19:15:01', '43.00', 2, NULL),
(347, '2024-05-13 19:15:01', '44.00', 3, NULL),
(348, '2024-05-13 19:15:02', '44.00', 2, NULL),
(349, '2024-05-13 19:15:02', '45.00', 3, NULL),
(350, '2024-05-13 19:15:03', '45.00', 2, NULL),
(351, '2024-05-13 19:15:03', '46.00', 3, NULL),
(352, '2024-05-13 19:15:04', '46.00', 2, NULL),
(353, '2024-05-13 19:15:04', '47.00', 3, NULL),
(354, '2024-05-13 19:15:05', '47.00', 2, NULL),
(355, '2024-05-13 19:15:05', '48.00', 3, NULL),
(356, '2024-05-13 19:15:06', '48.00', 2, NULL),
(357, '2024-05-13 19:15:06', '49.00', 3, NULL),
(358, '2024-05-13 19:15:07', '49.00', 2, NULL),
(359, '2024-05-13 19:15:07', '50.00', 3, NULL),
(360, '2024-05-13 19:15:20', '-37.00', 3, NULL),
(361, '2024-05-13 19:15:21', '-37.00', 2, NULL),
(362, '2024-05-13 19:15:21', '-36.00', 3, NULL),
(363, '2024-05-13 19:15:22', '-36.00', 2, NULL),
(364, '2024-05-13 19:15:22', '-35.00', 3, NULL),
(365, '2024-05-13 19:15:23', '-35.00', 2, NULL),
(366, '2024-05-13 19:15:23', '-34.00', 3, NULL),
(367, '2024-05-13 19:15:24', '-34.00', 2, NULL),
(368, '2024-05-13 19:15:24', '-33.00', 3, NULL),
(369, '2024-05-13 19:15:25', '-33.00', 2, NULL),
(370, '2024-05-13 19:15:25', '-32.00', 3, NULL),
(371, '2024-05-13 19:15:26', '-32.00', 2, NULL),
(372, '2024-05-13 19:15:26', '-31.00', 3, NULL),
(373, '2024-05-13 19:15:27', '-31.00', 2, NULL),
(374, '2024-05-13 19:15:27', '-30.00', 3, NULL),
(375, '2024-05-13 19:15:28', '-30.00', 2, NULL),
(376, '2024-05-13 19:15:28', '-29.00', 3, NULL),
(377, '2024-05-13 19:15:29', '-29.00', 2, NULL),
(378, '2024-05-13 19:15:29', '-28.00', 3, NULL),
(379, '2024-05-13 19:15:30', '-28.00', 2, NULL),
(380, '2024-05-13 19:15:30', '-27.00', 3, NULL),
(381, '2024-05-13 19:15:31', '-27.00', 2, NULL),
(382, '2024-05-13 19:15:31', '-26.00', 3, NULL),
(383, '2024-05-13 19:15:32', '-26.00', 2, NULL),
(384, '2024-05-13 19:15:32', '-25.00', 3, NULL),
(385, '2024-05-13 19:15:33', '-25.00', 2, NULL),
(386, '2024-05-13 19:15:33', '-24.00', 3, NULL),
(387, '2024-05-13 19:15:34', '-24.00', 2, NULL),
(388, '2024-05-13 19:15:34', '-23.00', 3, NULL),
(389, '2024-05-13 19:15:35', '-23.00', 2, NULL),
(390, '2024-05-13 19:15:35', '-22.00', 3, NULL),
(391, '2024-05-13 19:15:36', '-22.00', 2, NULL),
(392, '2024-05-13 19:15:36', '-21.00', 3, NULL),
(393, '2024-05-13 19:15:37', '-21.00', 2, NULL),
(394, '2024-05-13 19:15:37', '-20.00', 3, NULL),
(395, '2024-05-13 19:15:38', '-20.00', 2, NULL),
(396, '2024-05-13 19:15:38', '-19.00', 3, NULL),
(397, '2024-05-13 19:15:39', '-19.00', 2, NULL),
(398, '2024-05-13 19:15:39', '-18.00', 3, NULL),
(399, '2024-05-13 19:15:40', '-18.00', 2, NULL),
(400, '2024-05-13 19:15:40', '-17.00', 3, NULL),
(401, '2024-05-13 19:15:41', '-17.00', 2, NULL),
(402, '2024-05-13 19:15:41', '-16.00', 3, NULL),
(403, '2024-05-13 19:15:42', '-16.00', 2, NULL),
(404, '2024-05-13 19:15:42', '-15.00', 3, NULL),
(405, '2024-05-13 19:15:43', '-15.00', 2, NULL),
(406, '2024-05-13 19:15:43', '-14.00', 3, NULL),
(407, '2024-05-13 19:15:44', '-14.00', 2, NULL),
(408, '2024-05-13 19:15:44', '-13.00', 3, NULL),
(409, '2024-05-13 19:15:45', '-13.00', 2, NULL),
(410, '2024-05-13 19:15:45', '-12.00', 3, NULL),
(411, '2024-05-13 19:15:46', '-12.00', 2, NULL),
(412, '2024-05-13 19:15:46', '-11.00', 3, NULL),
(413, '2024-05-13 19:15:47', '-11.00', 2, NULL),
(414, '2024-05-13 19:15:47', '-10.00', 3, NULL),
(415, '2024-05-13 19:15:48', '-10.00', 2, NULL),
(416, '2024-05-13 19:15:48', '-9.00', 3, NULL),
(417, '2024-05-13 19:15:49', '-9.00', 2, NULL),
(418, '2024-05-13 19:15:49', '-8.00', 3, NULL),
(419, '2024-05-13 19:15:50', '-8.00', 2, NULL),
(420, '2024-05-13 19:15:50', '-7.00', 3, NULL),
(421, '2024-05-13 19:15:51', '-7.00', 2, NULL),
(422, '2024-05-13 19:15:51', '-6.00', 3, NULL),
(423, '2024-05-13 19:15:52', '-6.00', 2, NULL),
(424, '2024-05-13 19:15:52', '-5.00', 3, NULL),
(425, '2024-05-13 19:15:53', '-5.00', 2, NULL),
(426, '2024-05-13 19:15:53', '-4.00', 3, NULL),
(427, '2024-05-13 19:15:54', '-4.00', 2, NULL),
(428, '2024-05-13 19:15:54', '-3.00', 3, NULL),
(429, '2024-05-13 19:15:55', '-3.00', 2, NULL),
(430, '2024-05-13 19:15:55', '-2.00', 3, NULL),
(431, '2024-05-13 19:15:56', '-2.00', 2, NULL),
(432, '2024-05-13 19:15:56', '-1.00', 3, NULL),
(433, '2024-05-13 19:15:57', '-1.00', 2, NULL),
(434, '2024-05-13 19:15:57', '0.00', 3, NULL),
(435, '2024-05-13 19:15:58', '0.00', 2, NULL),
(436, '2024-05-13 19:15:58', '1.00', 3, NULL),
(437, '2024-05-13 19:15:59', '1.00', 2, NULL),
(438, '2024-05-13 19:15:59', '2.00', 3, NULL),
(439, '2024-05-13 19:16:00', '2.00', 2, NULL),
(440, '2024-05-13 19:16:00', '3.00', 3, NULL),
(441, '2024-05-13 19:16:01', '3.00', 2, NULL),
(442, '2024-05-13 19:16:01', '4.00', 3, NULL),
(443, '2024-05-13 19:16:02', '4.00', 2, NULL),
(444, '2024-05-13 19:16:02', '5.00', 3, NULL),
(445, '2024-05-13 19:16:03', '5.00', 2, NULL),
(446, '2024-05-13 19:16:03', '6.00', 3, NULL),
(447, '2024-05-13 19:16:04', '6.00', 2, NULL),
(448, '2024-05-13 19:16:04', '7.00', 3, NULL),
(449, '2024-05-13 19:16:05', '7.00', 2, NULL),
(450, '2024-05-13 19:16:05', '8.00', 3, NULL),
(451, '2024-05-13 19:16:06', '9.00', 3, NULL),
(452, '2024-05-13 19:16:06', '8.00', 2, NULL),
(453, '2024-05-13 19:16:07', '10.00', 3, NULL),
(454, '2024-05-13 19:16:07', '9.00', 2, NULL),
(455, '2024-05-13 19:16:08', '11.00', 3, NULL),
(456, '2024-05-13 19:16:08', '10.00', 2, NULL),
(457, '2024-05-13 19:16:09', '11.00', 2, NULL),
(458, '2024-05-13 19:16:09', '12.00', 3, NULL),
(459, '2024-05-13 19:16:10', '12.00', 2, NULL),
(460, '2024-05-13 19:16:10', '13.00', 3, NULL),
(461, '2024-05-13 19:16:11', '13.00', 2, NULL),
(462, '2024-05-13 19:16:11', '14.00', 3, NULL),
(463, '2024-05-13 19:16:12', '14.00', 2, NULL),
(464, '2024-05-13 19:16:12', '15.00', 3, NULL),
(465, '2024-05-13 19:16:13', '15.00', 2, NULL),
(466, '2024-05-13 19:16:13', '16.00', 3, NULL),
(467, '2024-05-13 19:16:14', '16.00', 2, NULL),
(468, '2024-05-13 19:16:14', '17.00', 3, NULL),
(469, '2024-05-13 19:16:15', '17.00', 2, NULL),
(470, '2024-05-13 19:16:15', '18.00', 3, NULL),
(471, '2024-05-13 19:16:16', '18.00', 2, NULL),
(472, '2024-05-13 19:16:16', '19.00', 3, NULL),
(473, '2024-05-13 19:16:17', '19.00', 2, NULL),
(474, '2024-05-13 19:16:17', '20.00', 3, NULL),
(475, '2024-05-13 19:16:18', '20.00', 2, NULL),
(476, '2024-05-13 19:16:18', '21.00', 3, NULL),
(477, '2024-05-13 19:16:19', '21.00', 2, NULL),
(478, '2024-05-13 19:16:19', '22.00', 3, NULL),
(479, '2024-05-13 19:16:20', '22.00', 2, NULL),
(480, '2024-05-13 19:16:20', '23.00', 3, NULL),
(481, '2024-05-13 19:16:21', '23.00', 2, NULL),
(482, '2024-05-13 19:16:21', '24.00', 3, NULL),
(483, '2024-05-13 19:16:22', '24.00', 2, NULL),
(484, '2024-05-13 19:16:22', '25.00', 3, NULL),
(485, '2024-05-13 19:16:23', '25.00', 2, NULL),
(486, '2024-05-13 19:16:23', '26.00', 3, NULL),
(487, '2024-05-13 19:16:24', '26.00', 2, NULL),
(488, '2024-05-13 19:16:24', '27.00', 3, NULL),
(489, '2024-05-13 19:16:25', '27.00', 2, NULL),
(490, '2024-05-13 19:16:25', '28.00', 3, NULL),
(491, '2024-05-13 19:16:27', '28.00', 2, NULL),
(492, '2024-05-13 19:16:27', '29.00', 3, NULL),
(493, '2024-05-13 19:16:28', '29.00', 2, NULL),
(494, '2024-05-13 19:16:28', '30.00', 3, NULL),
(495, '2024-05-13 19:16:29', '30.00', 2, NULL),
(496, '2024-05-13 19:16:29', '31.00', 3, NULL),
(497, '2024-05-13 19:16:30', '31.00', 2, NULL),
(498, '2024-05-13 19:16:30', '32.00', 3, NULL),
(499, '2024-05-13 19:16:31', '32.00', 2, NULL),
(500, '2024-05-13 19:16:31', '33.00', 3, NULL),
(501, '2024-05-13 19:16:32', '33.00', 2, NULL),
(502, '2024-05-13 19:16:32', '34.00', 3, NULL),
(503, '2024-05-13 19:16:33', '34.00', 2, NULL),
(504, '2024-05-13 19:16:33', '35.00', 3, NULL),
(505, '2024-05-13 19:16:34', '35.00', 2, NULL),
(506, '2024-05-13 19:16:34', '36.00', 3, NULL),
(507, '2024-05-13 19:16:35', '36.00', 2, NULL),
(508, '2024-05-13 19:16:35', '37.00', 3, NULL),
(509, '2024-05-13 19:16:36', '37.00', 2, NULL),
(510, '2024-05-13 19:16:36', '38.00', 3, NULL),
(511, '2024-05-13 19:16:37', '38.00', 2, 40),
(512, '2024-05-13 19:16:37', '39.00', 3, 40),
(513, '2024-05-13 19:16:38', '39.00', 2, 40),
(514, '2024-05-13 19:16:38', '40.00', 3, 40),
(515, '2024-05-13 19:16:39', '40.00', 2, 40),
(516, '2024-05-13 19:16:39', '41.00', 3, 40),
(517, '2024-05-13 19:16:40', '41.00', 2, 40),
(518, '2024-05-13 19:16:40', '42.00', 3, 40),
(519, '2024-05-13 19:16:41', '42.00', 2, 40),
(520, '2024-05-13 19:16:41', '43.00', 3, 40),
(521, '2024-05-13 19:16:42', '43.00', 2, 40),
(522, '2024-05-13 19:16:42', '44.00', 3, 40),
(523, '2024-05-13 19:16:43', '44.00', 2, 40),
(524, '2024-05-13 19:16:43', '45.00', 3, 40),
(525, '2024-05-13 19:16:44', '45.00', 2, NULL),
(526, '2024-05-13 19:16:44', '46.00', 3, NULL),
(527, '2024-05-13 19:16:45', '46.00', 2, NULL),
(528, '2024-05-13 19:16:45', '47.00', 3, NULL),
(529, '2024-05-13 19:16:46', '47.00', 2, NULL),
(530, '2024-05-13 19:16:46', '48.00', 3, NULL),
(531, '2024-05-13 19:16:47', '48.00', 2, NULL),
(532, '2024-05-13 19:16:47', '49.00', 3, NULL),
(533, '2024-05-13 19:16:48', '49.00', 2, NULL),
(534, '2024-05-13 19:16:48', '50.00', 3, NULL),
(535, '2024-05-13 19:17:01', '-37.00', 3, NULL),
(536, '2024-05-13 19:17:02', '-37.00', 2, NULL),
(537, '2024-05-13 19:17:02', '-36.00', 3, NULL),
(538, '2024-05-13 19:17:03', '-36.00', 2, NULL),
(539, '2024-05-13 19:17:03', '-35.00', 3, NULL),
(540, '2024-05-13 19:17:04', '-35.00', 2, NULL),
(541, '2024-05-13 19:17:04', '-34.00', 3, NULL),
(542, '2024-05-13 19:17:05', '-34.00', 2, NULL),
(543, '2024-05-13 19:17:05', '-33.00', 3, NULL),
(544, '2024-05-13 19:17:06', '-33.00', 2, NULL),
(545, '2024-05-13 19:17:06', '-32.00', 3, NULL),
(546, '2024-05-13 19:17:07', '-32.00', 2, NULL),
(547, '2024-05-13 19:17:07', '-31.00', 3, NULL),
(548, '2024-05-13 19:17:08', '-31.00', 2, NULL),
(549, '2024-05-13 19:17:08', '-30.00', 3, NULL),
(550, '2024-05-13 19:17:09', '-30.00', 2, NULL),
(551, '2024-05-13 19:17:09', '-29.00', 3, NULL),
(552, '2024-05-13 19:17:10', '-29.00', 2, NULL),
(553, '2024-05-13 19:17:10', '-28.00', 3, NULL),
(554, '2024-05-13 19:17:11', '-28.00', 2, NULL),
(555, '2024-05-13 19:17:11', '-27.00', 3, NULL),
(556, '2024-05-13 19:17:12', '-27.00', 2, NULL),
(557, '2024-05-13 19:17:12', '-26.00', 3, NULL),
(558, '2024-05-13 19:17:13', '-26.00', 2, NULL),
(559, '2024-05-13 19:17:13', '-25.00', 3, NULL),
(560, '2024-05-13 19:17:14', '-25.00', 2, NULL),
(561, '2024-05-13 19:17:14', '-24.00', 3, NULL),
(562, '2024-05-13 19:17:15', '-24.00', 2, NULL),
(563, '2024-05-13 19:17:15', '-23.00', 3, NULL),
(564, '2024-05-13 19:17:16', '-22.00', 3, NULL),
(565, '2024-05-13 19:17:16', '-23.00', 2, NULL),
(566, '2024-05-13 19:17:17', '-22.00', 2, NULL),
(567, '2024-05-13 19:17:17', '-21.00', 3, NULL),
(568, '2024-05-13 19:17:18', '-21.00', 2, NULL),
(569, '2024-05-13 19:17:18', '-20.00', 3, NULL),
(570, '2024-05-13 19:17:19', '-20.00', 2, NULL),
(571, '2024-05-13 19:17:19', '-19.00', 3, NULL),
(572, '2024-05-13 19:17:20', '-19.00', 2, NULL),
(573, '2024-05-13 19:17:20', '-18.00', 3, NULL),
(574, '2024-05-13 19:17:21', '-18.00', 2, NULL),
(575, '2024-05-13 19:17:21', '-17.00', 3, NULL),
(576, '2024-05-13 19:17:22', '-17.00', 2, NULL),
(577, '2024-05-13 19:17:22', '-16.00', 3, NULL),
(578, '2024-05-13 19:17:23', '-16.00', 2, NULL),
(579, '2024-05-13 19:17:23', '-15.00', 3, NULL),
(580, '2024-05-13 19:17:24', '-15.00', 2, NULL),
(581, '2024-05-13 19:17:24', '-14.00', 3, NULL),
(582, '2024-05-13 19:17:25', '-14.00', 2, NULL),
(583, '2024-05-13 19:17:25', '-13.00', 3, NULL),
(584, '2024-05-13 19:17:26', '-13.00', 2, NULL),
(585, '2024-05-13 19:17:26', '-12.00', 3, NULL),
(586, '2024-05-13 19:17:27', '-11.00', 3, NULL),
(587, '2024-05-13 19:17:27', '-12.00', 2, NULL),
(588, '2024-05-13 19:17:28', '-11.00', 2, NULL),
(589, '2024-05-13 19:17:28', '-10.00', 3, NULL),
(590, '2024-05-13 19:17:29', '-10.00', 2, NULL),
(591, '2024-05-13 19:17:29', '-9.00', 3, NULL),
(592, '2024-05-13 19:17:30', '-8.00', 3, NULL),
(593, '2024-05-13 19:17:30', '-9.00', 2, NULL),
(594, '2024-05-13 19:17:31', '-7.00', 3, NULL),
(595, '2024-05-13 19:17:31', '-8.00', 2, NULL),
(596, '2024-05-13 19:17:32', '-6.00', 3, NULL),
(597, '2024-05-13 19:17:32', '-7.00', 2, NULL),
(598, '2024-05-13 19:17:33', '-5.00', 3, NULL),
(599, '2024-05-13 19:17:33', '-6.00', 2, NULL),
(600, '2024-05-13 19:17:34', '-4.00', 3, NULL),
(601, '2024-05-13 19:17:34', '-5.00', 2, NULL),
(602, '2024-05-13 19:17:35', '-3.00', 3, NULL),
(603, '2024-05-13 19:17:35', '-4.00', 2, NULL),
(604, '2024-05-13 19:17:36', '-2.00', 3, NULL),
(605, '2024-05-13 19:17:36', '-3.00', 2, NULL),
(606, '2024-05-13 19:17:37', '-1.00', 3, NULL),
(607, '2024-05-13 19:17:37', '-2.00', 2, NULL),
(608, '2024-05-13 19:17:38', '0.00', 3, NULL),
(609, '2024-05-13 19:17:38', '-1.00', 2, NULL),
(610, '2024-05-13 19:17:39', '0.00', 2, NULL),
(611, '2024-05-13 19:17:39', '1.00', 3, NULL),
(612, '2024-05-13 19:17:40', '1.00', 2, NULL),
(613, '2024-05-13 19:17:40', '2.00', 3, NULL),
(614, '2024-05-13 19:17:41', '2.00', 2, NULL),
(615, '2024-05-13 19:17:41', '3.00', 3, NULL),
(616, '2024-05-13 19:17:42', '3.00', 2, NULL),
(617, '2024-05-13 19:17:42', '4.00', 3, NULL),
(618, '2024-05-13 19:17:43', '4.00', 2, NULL),
(619, '2024-05-13 19:17:43', '5.00', 3, NULL),
(620, '2024-05-13 19:17:44', '5.00', 2, NULL),
(621, '2024-05-13 19:17:44', '6.00', 3, NULL),
(622, '2024-05-13 19:17:45', '6.00', 2, NULL),
(623, '2024-05-13 19:17:45', '7.00', 3, NULL),
(624, '2024-05-13 19:17:46', '7.00', 2, NULL),
(625, '2024-05-13 19:17:46', '8.00', 3, NULL),
(626, '2024-05-13 19:17:47', '8.00', 2, NULL),
(627, '2024-05-13 19:17:47', '9.00', 3, NULL),
(628, '2024-05-13 19:17:48', '9.00', 2, NULL),
(629, '2024-05-13 19:17:48', '10.00', 3, NULL),
(630, '2024-05-13 19:17:49', '10.00', 2, NULL),
(631, '2024-05-13 19:17:49', '11.00', 3, NULL),
(632, '2024-05-13 19:17:50', '11.00', 2, NULL),
(633, '2024-05-13 19:17:50', '12.00', 3, NULL),
(634, '2024-05-13 19:17:51', '12.00', 2, NULL),
(635, '2024-05-13 19:17:51', '13.00', 3, NULL),
(636, '2024-05-13 19:17:52', '13.00', 2, NULL),
(637, '2024-05-13 19:17:52', '14.00', 3, NULL),
(638, '2024-05-13 19:17:53', '14.00', 2, NULL),
(639, '2024-05-13 19:17:53', '15.00', 3, NULL),
(640, '2024-05-13 19:17:54', '15.00', 2, NULL),
(641, '2024-05-13 19:17:54', '16.00', 3, NULL),
(642, '2024-05-13 19:17:55', '16.00', 2, NULL),
(643, '2024-05-13 19:17:55', '17.00', 3, NULL),
(644, '2024-05-13 19:17:56', '17.00', 2, NULL),
(645, '2024-05-13 19:17:56', '18.00', 3, NULL),
(646, '2024-05-13 19:17:57', '18.00', 2, NULL),
(647, '2024-05-13 19:17:57', '19.00', 3, NULL),
(648, '2024-05-13 19:17:58', '19.00', 2, NULL),
(649, '2024-05-13 19:17:58', '20.00', 3, NULL),
(650, '2024-05-13 19:17:59', '20.00', 2, NULL),
(651, '2024-05-13 19:17:59', '21.00', 3, NULL),
(652, '2024-05-13 19:18:00', '21.00', 2, NULL),
(653, '2024-05-13 19:18:00', '22.00', 3, NULL),
(654, '2024-05-13 19:18:01', '22.00', 2, NULL),
(655, '2024-05-13 19:18:01', '23.00', 3, NULL),
(656, '2024-05-13 19:18:02', '23.00', 2, NULL),
(657, '2024-05-13 19:18:02', '24.00', 3, NULL),
(658, '2024-05-13 19:18:03', '25.00', 3, NULL),
(659, '2024-05-13 19:18:03', '24.00', 2, NULL),
(660, '2024-05-13 19:18:04', '26.00', 3, NULL),
(661, '2024-05-13 19:18:04', '25.00', 2, NULL),
(662, '2024-05-13 19:18:05', '27.00', 3, NULL),
(663, '2024-05-13 19:18:05', '26.00', 2, NULL),
(664, '2024-05-13 19:18:06', '28.00', 3, NULL),
(665, '2024-05-13 19:18:06', '27.00', 2, NULL),
(666, '2024-05-13 19:18:07', '29.00', 3, NULL),
(667, '2024-05-13 19:18:07', '28.00', 2, NULL),
(668, '2024-05-13 19:18:08', '30.00', 3, NULL),
(669, '2024-05-13 19:18:08', '29.00', 2, NULL),
(670, '2024-05-13 19:18:09', '31.00', 3, NULL),
(671, '2024-05-13 19:18:09', '30.00', 2, NULL),
(672, '2024-05-13 19:18:10', '32.00', 3, NULL),
(673, '2024-05-13 19:18:10', '31.00', 2, NULL),
(674, '2024-05-13 19:18:11', '33.00', 3, NULL),
(675, '2024-05-13 19:18:11', '32.00', 2, NULL),
(676, '2024-05-13 19:18:12', '34.00', 3, NULL),
(677, '2024-05-13 19:18:12', '33.00', 2, NULL),
(678, '2024-05-13 19:18:13', '35.00', 3, NULL),
(679, '2024-05-13 19:18:13', '34.00', 2, NULL),
(680, '2024-05-13 19:18:14', '36.00', 3, NULL),
(681, '2024-05-13 19:18:14', '35.00', 2, NULL),
(682, '2024-05-13 19:18:15', '37.00', 3, NULL),
(683, '2024-05-13 19:18:15', '36.00', 2, NULL),
(684, '2024-05-13 19:18:16', '38.00', 3, NULL),
(685, '2024-05-13 19:18:16', '37.00', 2, NULL),
(686, '2024-05-13 19:18:17', '39.00', 3, NULL),
(687, '2024-05-13 19:18:17', '38.00', 2, NULL),
(688, '2024-05-13 19:18:18', '40.00', 3, NULL),
(689, '2024-05-13 19:18:18', '39.00', 2, NULL),
(690, '2024-05-13 19:18:19', '40.00', 2, NULL),
(691, '2024-05-13 19:18:19', '41.00', 3, NULL),
(692, '2024-05-13 19:18:20', '41.00', 2, NULL),
(693, '2024-05-13 19:18:20', '42.00', 3, NULL),
(694, '2024-05-13 19:18:21', '43.00', 3, NULL),
(695, '2024-05-13 19:18:21', '42.00', 2, NULL),
(696, '2024-05-13 19:18:22', '44.00', 3, NULL),
(697, '2024-05-13 19:18:22', '43.00', 2, NULL),
(698, '2024-05-13 19:18:23', '45.00', 3, NULL),
(699, '2024-05-13 19:18:23', '44.00', 2, NULL),
(700, '2024-05-13 19:18:25', '46.00', 3, NULL),
(701, '2024-05-13 19:18:25', '45.00', 2, NULL),
(702, '2024-05-13 19:18:26', '47.00', 3, NULL),
(703, '2024-05-13 19:18:26', '46.00', 2, NULL),
(704, '2024-05-13 19:18:27', '48.00', 3, NULL),
(705, '2024-05-13 19:18:27', '47.00', 2, NULL),
(706, '2024-05-13 19:18:28', '49.00', 3, NULL),
(707, '2024-05-13 19:18:28', '48.00', 2, NULL),
(708, '2024-05-13 19:18:29', '49.00', 2, NULL),
(709, '2024-05-13 19:18:29', '50.00', 3, NULL),
(710, '2024-05-13 19:18:46', '-36.00', 2, NULL),
(711, '2024-05-13 19:18:48', '-35.00', 2, NULL),
(712, '2024-05-13 19:18:50', '-34.00', 2, NULL),
(713, '2024-05-13 19:18:52', '-33.00', 2, NULL),
(714, '2024-05-13 19:18:54', '-32.00', 2, NULL),
(715, '2024-05-13 19:18:56', '-31.00', 2, NULL),
(716, '2024-05-13 19:18:58', '-30.00', 2, NULL),
(717, '2024-05-13 19:19:00', '-29.00', 2, NULL),
(718, '2024-05-13 19:19:02', '-28.00', 2, NULL),
(719, '2024-05-13 19:19:04', '-27.00', 2, NULL),
(720, '2024-05-13 19:19:06', '-26.00', 2, NULL),
(721, '2024-05-13 19:19:08', '-25.00', 2, NULL),
(722, '2024-05-13 19:19:10', '-24.00', 2, NULL),
(723, '2024-05-13 19:19:12', '-23.00', 2, NULL),
(724, '2024-05-13 19:19:14', '-22.00', 2, NULL),
(725, '2024-05-13 19:19:16', '-21.00', 2, NULL),
(726, '2024-05-13 19:19:18', '-20.00', 2, NULL),
(727, '2024-05-13 19:19:20', '-19.00', 2, NULL),
(728, '2024-05-13 19:19:22', '-18.00', 2, NULL),
(729, '2024-05-13 19:19:24', '-17.00', 2, NULL),
(730, '2024-05-13 19:19:26', '-16.00', 2, NULL),
(731, '2024-05-13 19:19:28', '-15.00', 2, NULL),
(732, '2024-05-13 19:19:30', '-14.00', 2, NULL),
(733, '2024-05-13 19:19:32', '-13.00', 2, NULL),
(734, '2024-05-13 19:19:34', '-12.00', 2, NULL),
(735, '2024-05-13 19:19:36', '-11.00', 2, NULL),
(736, '2024-05-13 19:19:38', '-10.00', 2, NULL),
(737, '2024-05-13 19:19:40', '-9.00', 2, NULL),
(738, '2024-05-13 19:20:21', '1.00', 2, NULL),
(739, '2024-05-13 19:20:21', '2.00', 3, NULL),
(740, '2024-05-13 19:20:22', '2.00', 2, NULL),
(741, '2024-05-13 19:20:22', '3.00', 3, NULL),
(742, '2024-05-13 19:20:23', '3.00', 2, NULL),
(743, '2024-05-13 19:20:23', '4.00', 3, NULL),
(744, '2024-05-13 19:20:24', '4.00', 2, NULL),
(745, '2024-05-13 19:20:24', '5.00', 3, NULL),
(746, '2024-05-13 19:20:25', '5.00', 2, NULL),
(747, '2024-05-13 19:20:25', '6.00', 3, NULL),
(748, '2024-05-13 19:20:26', '6.00', 2, NULL),
(749, '2024-05-13 19:20:26', '7.00', 3, NULL),
(750, '2024-05-13 19:20:27', '7.00', 2, NULL),
(751, '2024-05-13 19:20:27', '8.00', 3, NULL),
(752, '2024-05-13 19:20:28', '8.00', 2, NULL),
(753, '2024-05-13 19:20:28', '9.00', 3, NULL),
(754, '2024-05-13 19:20:29', '9.00', 2, NULL),
(755, '2024-05-13 19:20:29', '10.00', 3, NULL),
(756, '2024-05-13 19:20:30', '10.00', 2, NULL),
(757, '2024-05-13 19:20:30', '11.00', 3, NULL),
(758, '2024-05-13 19:20:31', '11.00', 2, NULL),
(759, '2024-05-13 19:20:31', '12.00', 3, NULL),
(760, '2024-05-13 19:20:32', '12.00', 2, NULL),
(761, '2024-05-13 19:20:32', '13.00', 3, NULL),
(762, '2024-05-13 19:20:33', '13.00', 2, NULL),
(763, '2024-05-13 19:20:33', '14.00', 3, NULL),
(764, '2024-05-13 19:20:34', '14.00', 2, NULL),
(765, '2024-05-13 19:20:34', '15.00', 3, NULL),
(766, '2024-05-13 19:20:35', '15.00', 2, NULL),
(767, '2024-05-13 19:20:35', '16.00', 3, NULL),
(768, '2024-05-13 19:20:36', '16.00', 2, NULL),
(769, '2024-05-13 19:20:36', '17.00', 3, NULL),
(770, '2024-05-13 19:20:37', '17.00', 2, NULL),
(771, '2024-05-13 19:20:37', '18.00', 3, NULL),
(772, '2024-05-13 19:20:38', '18.00', 2, NULL),
(773, '2024-05-13 19:20:38', '19.00', 3, NULL),
(774, '2024-05-13 19:20:39', '19.00', 2, NULL),
(775, '2024-05-13 19:20:39', '20.00', 3, NULL),
(776, '2024-05-13 19:20:40', '20.00', 2, NULL),
(777, '2024-05-13 19:20:40', '21.00', 3, NULL),
(778, '2024-05-13 19:20:41', '21.00', 2, NULL),
(779, '2024-05-13 19:20:41', '22.00', 3, NULL),
(780, '2024-05-13 19:20:42', '22.00', 2, NULL),
(781, '2024-05-13 19:20:42', '23.00', 3, NULL),
(782, '2024-05-13 19:20:43', '23.00', 2, NULL),
(783, '2024-05-13 19:20:43', '24.00', 3, NULL),
(784, '2024-05-13 19:20:44', '24.00', 2, NULL),
(785, '2024-05-13 19:20:44', '25.00', 3, NULL),
(786, '2024-05-13 19:20:45', '25.00', 2, NULL),
(787, '2024-05-13 19:20:45', '26.00', 3, NULL),
(788, '2024-05-13 19:20:46', '26.00', 2, NULL),
(789, '2024-05-13 19:20:46', '27.00', 3, NULL),
(790, '2024-05-13 19:20:47', '27.00', 2, NULL),
(791, '2024-05-13 19:20:47', '28.00', 3, NULL),
(792, '2024-05-13 19:20:48', '28.00', 2, NULL),
(793, '2024-05-13 19:20:48', '29.00', 3, NULL),
(794, '2024-05-13 19:20:49', '29.00', 2, NULL),
(795, '2024-05-13 19:20:49', '30.00', 3, NULL),
(796, '2024-05-13 19:20:50', '30.00', 2, NULL),
(797, '2024-05-13 19:20:50', '31.00', 3, NULL),
(798, '2024-05-13 19:20:51', '31.00', 2, NULL),
(799, '2024-05-13 19:20:51', '32.00', 3, NULL),
(800, '2024-05-13 19:20:52', '32.00', 2, NULL),
(801, '2024-05-13 19:20:52', '33.00', 3, NULL),
(802, '2024-05-13 19:20:53', '33.00', 2, NULL),
(803, '2024-05-13 19:20:53', '34.00', 3, NULL),
(804, '2024-05-13 19:20:54', '34.00', 2, NULL),
(805, '2024-05-13 19:20:54', '35.00', 3, NULL),
(806, '2024-05-13 19:20:55', '35.00', 2, NULL),
(807, '2024-05-13 19:20:55', '36.00', 3, NULL),
(808, '2024-05-13 19:20:56', '36.00', 2, NULL),
(809, '2024-05-13 19:20:56', '37.00', 3, NULL),
(810, '2024-05-13 19:20:57', '37.00', 2, NULL),
(811, '2024-05-13 19:20:57', '38.00', 3, NULL),
(812, '2024-05-13 19:20:58', '38.00', 2, NULL),
(813, '2024-05-13 19:20:58', '39.00', 3, NULL),
(814, '2024-05-13 19:20:59', '39.00', 2, NULL),
(815, '2024-05-13 19:20:59', '40.00', 3, NULL),
(816, '2024-05-13 19:21:00', '40.00', 2, NULL),
(817, '2024-05-13 19:21:00', '41.00', 3, NULL),
(818, '2024-05-13 19:21:01', '41.00', 2, NULL),
(819, '2024-05-13 19:21:01', '42.00', 3, NULL),
(820, '2024-05-13 19:21:02', '42.00', 2, NULL),
(821, '2024-05-13 19:21:02', '43.00', 3, NULL),
(822, '2024-05-13 19:21:03', '43.00', 2, NULL),
(823, '2024-05-13 19:21:03', '44.00', 3, NULL),
(824, '2024-05-13 19:21:04', '44.00', 2, NULL),
(825, '2024-05-13 19:21:04', '45.00', 3, NULL),
(826, '2024-05-13 19:21:05', '45.00', 2, NULL),
(827, '2024-05-13 19:21:05', '46.00', 3, NULL),
(828, '2024-05-13 19:21:06', '46.00', 2, NULL),
(829, '2024-05-13 19:21:06', '47.00', 3, NULL),
(830, '2024-05-13 19:21:07', '47.00', 2, NULL),
(831, '2024-05-13 19:21:07', '48.00', 3, NULL),
(832, '2024-05-13 19:21:08', '48.00', 2, NULL),
(833, '2024-05-13 19:21:08', '49.00', 3, NULL),
(834, '2024-05-13 19:21:09', '49.00', 2, NULL),
(835, '2024-05-13 19:21:09', '50.00', 3, 41),
(836, '2024-05-13 19:21:10', '51.00', 3, 41),
(837, '2024-05-13 19:21:11', '50.00', 3, 41),
(838, '2024-05-13 19:21:12', '49.00', 3, 41),
(839, '2024-05-13 19:21:13', '48.00', 3, 41),
(840, '2024-05-13 19:21:14', '47.00', 3, NULL),
(841, '2024-05-13 19:21:15', '46.00', 3, NULL),
(842, '2024-05-13 19:21:16', '45.00', 3, NULL),
(843, '2024-05-13 19:21:17', '44.00', 3, NULL),
(844, '2024-05-13 19:21:18', '43.00', 3, NULL),
(845, '2024-05-13 19:21:19', '42.00', 3, NULL),
(846, '2024-05-13 19:21:20', '41.00', 3, NULL),
(847, '2024-05-13 19:21:21', '40.00', 3, NULL),
(848, '2024-05-13 19:21:22', '39.00', 3, NULL),
(849, '2024-05-13 19:21:23', '38.00', 3, NULL),
(850, '2024-05-13 19:21:24', '37.00', 3, NULL),
(851, '2024-05-13 19:21:26', '36.00', 3, NULL),
(852, '2024-05-13 19:21:27', '35.00', 3, NULL),
(853, '2024-05-13 19:21:28', '34.00', 3, NULL),
(854, '2024-05-13 19:21:29', '33.00', 3, NULL),
(855, '2024-05-13 19:21:30', '32.00', 3, NULL),
(856, '2024-05-13 19:21:31', '31.00', 3, NULL),
(857, '2024-05-13 19:21:32', '30.00', 3, NULL),
(858, '2024-05-13 19:21:33', '29.00', 3, NULL),
(859, '2024-05-13 19:21:34', '28.00', 3, NULL),
(860, '2024-05-13 19:21:35', '27.00', 3, NULL),
(861, '2024-05-13 19:21:36', '-25.00', 2, NULL),
(862, '2024-05-13 19:21:36', '26.00', 3, NULL),
(863, '2024-05-13 19:21:37', '-24.00', 2, NULL),
(864, '2024-05-13 19:21:37', '25.00', 3, NULL),
(865, '2024-05-13 19:21:38', '-23.00', 2, NULL),
(866, '2024-05-13 19:21:38', '24.00', 3, NULL),
(867, '2024-05-13 19:21:39', '-22.00', 2, NULL),
(868, '2024-05-13 19:21:39', '23.00', 3, NULL),
(869, '2024-05-13 19:21:42', '1.00', 2, NULL),
(870, '2024-05-13 19:21:42', '2.00', 3, NULL),
(871, '2024-05-13 19:21:43', '2.00', 2, NULL),
(872, '2024-05-13 19:21:43', '3.00', 3, NULL),
(873, '2024-05-13 19:21:44', '3.00', 2, NULL),
(874, '2024-05-13 19:21:44', '4.00', 3, NULL),
(875, '2024-05-13 19:21:45', '4.00', 2, NULL),
(876, '2024-05-13 19:21:45', '5.00', 3, NULL),
(877, '2024-05-13 19:21:46', '5.00', 2, NULL),
(878, '2024-05-13 19:21:46', '6.00', 3, NULL),
(879, '2024-05-13 19:21:47', '6.00', 2, NULL),
(880, '2024-05-13 19:21:47', '7.00', 3, NULL),
(881, '2024-05-13 19:21:48', '7.00', 2, NULL),
(882, '2024-05-13 19:21:48', '8.00', 3, NULL),
(883, '2024-05-13 19:21:49', '8.00', 2, NULL),
(884, '2024-05-13 19:21:49', '9.00', 3, NULL),
(885, '2024-05-13 19:21:50', '9.00', 2, NULL),
(886, '2024-05-13 19:21:50', '10.00', 3, NULL),
(887, '2024-05-13 19:21:51', '10.00', 2, NULL),
(888, '2024-05-13 19:21:51', '11.00', 3, NULL),
(889, '2024-05-13 19:21:52', '11.00', 2, NULL),
(890, '2024-05-13 19:21:52', '12.00', 3, NULL),
(891, '2024-05-13 19:21:53', '12.00', 2, NULL),
(892, '2024-05-13 19:21:53', '13.00', 3, NULL),
(893, '2024-05-13 19:21:54', '13.00', 2, NULL),
(894, '2024-05-13 19:21:54', '14.00', 3, NULL),
(895, '2024-05-13 19:21:55', '14.00', 2, NULL),
(896, '2024-05-13 19:21:55', '15.00', 3, NULL),
(897, '2024-05-13 19:21:56', '15.00', 2, NULL),
(898, '2024-05-13 19:21:56', '16.00', 3, NULL),
(899, '2024-05-13 19:21:57', '16.00', 2, NULL),
(900, '2024-05-13 19:21:57', '17.00', 3, NULL),
(901, '2024-05-13 19:21:58', '17.00', 2, NULL),
(902, '2024-05-13 19:21:58', '18.00', 3, NULL),
(903, '2024-05-13 19:21:59', '18.00', 2, NULL),
(904, '2024-05-13 19:21:59', '19.00', 3, NULL),
(905, '2024-05-13 19:22:00', '19.00', 2, NULL),
(906, '2024-05-13 19:22:00', '20.00', 3, NULL),
(907, '2024-05-13 19:22:01', '20.00', 2, NULL),
(908, '2024-05-13 19:22:01', '21.00', 3, NULL),
(909, '2024-05-13 19:22:02', '21.00', 2, NULL),
(910, '2024-05-13 19:22:02', '22.00', 3, NULL),
(911, '2024-05-13 19:22:03', '22.00', 2, NULL),
(912, '2024-05-13 19:22:03', '23.00', 3, NULL),
(913, '2024-05-13 19:22:04', '23.00', 2, NULL),
(914, '2024-05-13 19:22:04', '24.00', 3, NULL),
(915, '2024-05-13 19:22:05', '24.00', 2, NULL),
(916, '2024-05-13 19:22:05', '25.00', 3, NULL),
(917, '2024-05-13 19:22:06', '25.00', 2, NULL),
(918, '2024-05-13 19:22:06', '26.00', 3, NULL),
(919, '2024-05-13 19:22:07', '26.00', 2, NULL),
(920, '2024-05-13 19:22:07', '27.00', 3, NULL),
(921, '2024-05-13 19:22:08', '27.00', 2, NULL),
(922, '2024-05-13 19:22:08', '28.00', 3, NULL),
(923, '2024-05-13 19:22:09', '28.00', 2, NULL),
(924, '2024-05-13 19:22:09', '29.00', 3, NULL),
(925, '2024-05-13 19:22:10', '29.00', 2, NULL),
(926, '2024-05-13 19:22:10', '30.00', 3, NULL),
(927, '2024-05-13 19:22:11', '30.00', 2, NULL),
(928, '2024-05-13 19:22:11', '31.00', 3, NULL),
(929, '2024-05-13 19:22:12', '31.00', 2, NULL),
(930, '2024-05-13 19:22:12', '32.00', 3, NULL),
(931, '2024-05-13 19:22:13', '32.00', 2, NULL),
(932, '2024-05-13 19:22:13', '33.00', 3, NULL),
(933, '2024-05-13 19:22:14', '33.00', 2, NULL),
(934, '2024-05-13 19:22:14', '34.00', 3, NULL),
(935, '2024-05-13 19:22:15', '34.00', 2, NULL),
(936, '2024-05-13 19:22:15', '35.00', 3, NULL),
(937, '2024-05-13 19:22:16', '35.00', 2, NULL),
(938, '2024-05-13 19:22:16', '36.00', 3, NULL),
(939, '2024-05-13 19:22:17', '36.00', 2, NULL),
(940, '2024-05-13 19:22:17', '37.00', 3, NULL),
(941, '2024-05-13 19:22:18', '37.00', 2, NULL),
(942, '2024-05-13 19:22:18', '38.00', 3, NULL),
(943, '2024-05-13 19:22:19', '38.00', 2, NULL),
(944, '2024-05-13 19:22:19', '39.00', 3, NULL),
(945, '2024-05-13 19:22:20', '39.00', 2, NULL),
(946, '2024-05-13 19:22:20', '40.00', 3, NULL),
(947, '2024-05-13 19:22:21', '40.00', 2, NULL),
(948, '2024-05-13 19:22:21', '41.00', 3, NULL),
(949, '2024-05-13 19:22:22', '41.00', 2, NULL),
(950, '2024-05-13 19:22:22', '42.00', 3, NULL),
(951, '2024-05-13 19:22:23', '42.00', 2, NULL),
(952, '2024-05-13 19:22:23', '43.00', 3, NULL),
(953, '2024-05-13 19:22:24', '43.00', 2, NULL),
(954, '2024-05-13 19:22:24', '44.00', 3, NULL),
(955, '2024-05-13 19:22:25', '44.00', 2, NULL),
(956, '2024-05-13 19:22:25', '45.00', 3, NULL),
(957, '2024-05-13 19:22:26', '45.00', 2, NULL),
(958, '2024-05-13 19:22:26', '46.00', 3, NULL),
(959, '2024-05-13 19:22:27', '46.00', 2, NULL),
(960, '2024-05-13 19:22:27', '47.00', 3, NULL),
(961, '2024-05-13 19:22:28', '47.00', 2, NULL),
(962, '2024-05-13 19:22:28', '48.00', 3, NULL),
(963, '2024-05-13 19:22:29', '48.00', 2, NULL),
(964, '2024-05-13 19:22:29', '49.00', 3, NULL),
(965, '2024-05-13 19:22:30', '49.00', 2, NULL),
(966, '2024-05-13 19:22:30', '50.00', 3, NULL),
(967, '2024-05-13 19:22:31', '50.00', 2, NULL),
(968, '2024-05-13 19:22:31', '51.00', 3, NULL),
(969, '2024-05-13 19:22:32', '49.00', 2, NULL),
(970, '2024-05-13 19:22:32', '50.00', 3, NULL),
(971, '2024-05-13 19:22:33', '48.00', 2, NULL),
(972, '2024-05-13 19:22:33', '49.00', 3, NULL),
(973, '2024-05-13 19:22:34', '47.00', 2, NULL),
(974, '2024-05-13 19:22:34', '48.00', 3, NULL),
(975, '2024-05-13 19:22:35', '46.00', 2, NULL),
(976, '2024-05-13 19:22:35', '47.00', 3, NULL),
(977, '2024-05-13 19:22:36', '45.00', 2, NULL),
(978, '2024-05-13 19:22:36', '46.00', 3, NULL),
(979, '2024-05-13 19:22:37', '44.00', 2, NULL),
(980, '2024-05-13 19:22:37', '45.00', 3, NULL),
(981, '2024-05-13 19:22:38', '43.00', 2, NULL),
(982, '2024-05-13 19:22:38', '44.00', 3, NULL),
(983, '2024-05-13 19:22:39', '42.00', 2, NULL),
(984, '2024-05-13 19:22:39', '43.00', 3, NULL),
(985, '2024-05-13 19:22:40', '41.00', 2, NULL),
(986, '2024-05-13 19:22:40', '42.00', 3, NULL),
(987, '2024-05-13 19:22:41', '40.00', 2, NULL),
(988, '2024-05-13 19:22:41', '41.00', 3, NULL),
(989, '2024-05-13 19:22:42', '39.00', 2, NULL),
(990, '2024-05-13 19:22:42', '40.00', 3, NULL),
(991, '2024-05-13 19:22:43', '38.00', 2, NULL),
(992, '2024-05-13 19:22:43', '39.00', 3, NULL),
(993, '2024-05-13 19:22:44', '37.00', 2, NULL),
(994, '2024-05-13 19:22:44', '38.00', 3, NULL),
(995, '2024-05-13 19:22:45', '36.00', 2, NULL),
(996, '2024-05-13 19:22:45', '37.00', 3, NULL),
(997, '2024-05-13 19:22:46', '35.00', 2, NULL),
(998, '2024-05-13 19:22:46', '36.00', 3, NULL),
(999, '2024-05-13 19:22:47', '34.00', 2, 41),
(1000, '2024-05-13 19:22:47', '35.00', 3, 41),
(1001, '2024-05-13 19:22:49', '33.00', 2, 41),
(1002, '2024-05-13 19:22:49', '34.00', 3, 41),
(1003, '2024-05-13 19:22:50', '32.00', 2, 41),
(1004, '2024-05-13 19:22:50', '33.00', 3, 41),
(1005, '2024-05-13 19:22:51', '31.00', 2, 41),
(1006, '2024-05-13 19:22:51', '32.00', 3, 41),
(1007, '2024-05-13 19:22:52', '30.00', 2, 41),
(1008, '2024-05-13 19:22:52', '31.00', 3, 41),
(1009, '2024-05-13 19:22:53', '29.00', 2, 41),
(1010, '2024-05-13 19:22:53', '30.00', 3, 41),
(1011, '2024-05-13 19:22:54', '28.00', 2, 41),
(1012, '2024-05-13 19:22:54', '29.00', 3, 41),
(1013, '2024-05-13 19:22:55', '27.00', 2, 41),
(1014, '2024-05-13 19:22:55', '28.00', 3, 41),
(1015, '2024-05-13 19:22:56', '26.00', 2, 41),
(1016, '2024-05-13 19:22:56', '27.00', 3, 41),
(1017, '2024-05-13 19:22:57', '25.00', 2, 41),
(1018, '2024-05-13 19:22:57', '26.00', 3, 41),
(1019, '2024-05-13 19:22:58', '24.00', 2, 41),
(1020, '2024-05-13 19:22:58', '25.00', 3, 41),
(1021, '2024-05-13 19:22:59', '23.00', 2, 41),
(1022, '2024-05-13 19:22:59', '24.00', 3, 41),
(1023, '2024-05-13 19:23:00', '22.00', 2, 41),
(1024, '2024-05-13 19:23:00', '23.00', 3, 41),
(1025, '2024-05-13 19:23:01', '21.00', 2, 41),
(1026, '2024-05-13 19:23:01', '22.00', 3, 41),
(1027, '2024-05-13 19:23:02', '20.00', 2, 41),
(1028, '2024-05-13 19:23:02', '21.00', 3, 41),
(1029, '2024-05-13 19:23:03', '19.00', 2, 41),
(1030, '2024-05-13 19:23:03', '20.00', 3, 41),
(1031, '2024-05-13 19:23:04', '18.00', 2, 41),
(1032, '2024-05-13 19:23:04', '19.00', 3, 41),
(1033, '2024-05-13 19:23:05', '17.00', 2, 41),
(1034, '2024-05-13 19:23:05', '18.00', 3, 41),
(1035, '2024-05-13 19:23:06', '16.00', 2, 41),
(1036, '2024-05-13 19:23:06', '17.00', 3, 41),
(1037, '2024-05-13 19:23:07', '15.00', 2, 41),
(1038, '2024-05-13 19:23:07', '16.00', 3, 41),
(1039, '2024-05-13 19:23:08', '14.00', 2, 41),
(1040, '2024-05-13 19:23:08', '15.00', 3, 41),
(1041, '2024-05-13 19:23:09', '13.00', 2, 41),
(1042, '2024-05-13 19:23:09', '14.00', 3, 41),
(1043, '2024-05-13 19:23:10', '12.00', 2, 41),
(1044, '2024-05-13 19:23:10', '13.00', 3, 41),
(1045, '2024-05-13 19:23:11', '11.00', 2, 41),
(1046, '2024-05-13 19:23:11', '12.00', 3, 41),
(1047, '2024-05-13 19:23:12', '10.00', 2, 41),
(1048, '2024-05-13 19:23:12', '11.00', 3, 41),
(1049, '2024-05-13 19:23:13', '9.00', 2, 41),
(1050, '2024-05-13 19:23:13', '10.00', 3, 41),
(1051, '2024-05-13 19:23:14', '8.00', 2, 41),
(1052, '2024-05-13 19:23:14', '9.00', 3, 41),
(1053, '2024-05-13 19:23:15', '7.00', 2, 41),
(1054, '2024-05-13 19:23:15', '8.00', 3, 41),
(1055, '2024-05-13 19:23:16', '6.00', 2, 41),
(1056, '2024-05-13 19:23:16', '7.00', 3, 41),
(1057, '2024-05-13 19:23:17', '5.00', 2, 41),
(1058, '2024-05-13 19:23:17', '6.00', 3, 41),
(1059, '2024-05-13 19:23:18', '4.00', 2, 41),
(1060, '2024-05-13 19:23:18', '5.00', 3, 41),
(1061, '2024-05-13 19:23:19', '3.00', 2, 41),
(1062, '2024-05-13 19:23:19', '4.00', 3, 41),
(1063, '2024-05-13 19:23:20', '2.00', 2, 41),
(1064, '2024-05-13 19:23:20', '3.00', 3, 41),
(1065, '2024-05-13 19:23:21', '1.00', 2, 41),
(1066, '2024-05-13 19:23:21', '2.00', 3, 41),
(1067, '2024-05-13 19:23:22', '0.00', 2, 41),
(1068, '2024-05-13 19:23:22', '1.00', 3, 41),
(1069, '2024-05-13 19:23:23', '1.00', 2, 41),
(1070, '2024-05-13 19:23:23', '2.00', 3, 41),
(1071, '2024-05-13 19:23:24', '2.00', 2, 41),
(1072, '2024-05-13 19:23:24', '3.00', 3, 41),
(1073, '2024-05-13 19:23:25', '3.00', 2, 41),
(1074, '2024-05-13 19:23:25', '4.00', 3, 41),
(1075, '2024-05-13 19:23:26', '4.00', 2, 41),
(1076, '2024-05-13 19:23:26', '5.00', 3, 41),
(1077, '2024-05-13 19:23:27', '5.00', 2, 41),
(1078, '2024-05-13 19:23:27', '6.00', 3, 41),
(1079, '2024-05-13 19:23:28', '6.00', 2, 41),
(1080, '2024-05-13 19:23:28', '7.00', 3, 41),
(1081, '2024-05-13 19:23:29', '7.00', 2, 41),
(1082, '2024-05-13 19:23:29', '8.00', 3, 41),
(1083, '2024-05-13 19:23:30', '8.00', 2, 41),
(1084, '2024-05-13 19:23:30', '9.00', 3, 41),
(1085, '2024-05-13 19:23:31', '9.00', 2, 41),
(1086, '2024-05-13 19:23:31', '10.00', 3, 41),
(1087, '2024-05-13 19:23:32', '10.00', 2, 41),
(1088, '2024-05-13 19:23:32', '11.00', 3, 41);
INSERT INTO `medicoestemperatura` (`IDMedição`, `DataHora`, `Leitura`, `Sensor`, `IDExperiencia`) VALUES
(1089, '2024-05-13 19:23:33', '11.00', 2, 41),
(1090, '2024-05-13 19:23:33', '12.00', 3, 41),
(1091, '2024-05-13 19:23:34', '12.00', 2, 41),
(1092, '2024-05-13 19:23:34', '13.00', 3, 41),
(1093, '2024-05-13 19:23:35', '13.00', 2, 41),
(1094, '2024-05-13 19:23:35', '14.00', 3, 41),
(1095, '2024-05-13 19:23:36', '14.00', 2, 41),
(1096, '2024-05-13 19:23:36', '15.00', 3, 41),
(1097, '2024-05-13 19:23:37', '15.00', 2, 41),
(1098, '2024-05-13 19:23:37', '16.00', 3, 41),
(1099, '2024-05-13 19:23:38', '16.00', 2, 41),
(1100, '2024-05-13 19:23:38', '17.00', 3, 41),
(1101, '2024-05-13 19:23:39', '17.00', 2, 41),
(1102, '2024-05-13 19:23:39', '18.00', 3, 41),
(1103, '2024-05-13 19:23:40', '18.00', 2, 41),
(1104, '2024-05-13 19:23:40', '19.00', 3, 41),
(1105, '2024-05-13 19:23:41', '19.00', 2, 41),
(1106, '2024-05-13 19:23:41', '20.00', 3, 41),
(1107, '2024-05-13 19:23:42', '20.00', 2, 41),
(1108, '2024-05-13 19:23:42', '21.00', 3, 41),
(1109, '2024-05-13 19:23:43', '21.00', 2, 41),
(1110, '2024-05-13 19:23:43', '22.00', 3, 41),
(1111, '2024-05-13 19:23:44', '22.00', 2, 41),
(1112, '2024-05-13 19:23:44', '23.00', 3, 41),
(1113, '2024-05-13 19:23:45', '23.00', 2, 41),
(1114, '2024-05-13 19:23:45', '24.00', 3, 41),
(1115, '2024-05-13 19:23:46', '24.00', 2, 41),
(1116, '2024-05-13 19:23:46', '25.00', 3, 41),
(1117, '2024-05-13 19:23:47', '25.00', 2, 41),
(1118, '2024-05-13 19:23:47', '26.00', 3, 41),
(1119, '2024-05-13 19:23:48', '26.00', 2, 41),
(1120, '2024-05-13 19:23:48', '27.00', 3, 41),
(1121, '2024-05-13 19:23:49', '27.00', 2, 41),
(1122, '2024-05-13 19:23:49', '28.00', 3, 41),
(1123, '2024-05-13 19:23:50', '28.00', 2, 41),
(1124, '2024-05-13 19:23:50', '29.00', 3, 41),
(1125, '2024-05-13 19:23:51', '29.00', 2, 41),
(1126, '2024-05-13 19:23:51', '30.00', 3, 41),
(1127, '2024-05-13 19:23:52', '30.00', 2, 41),
(1128, '2024-05-13 19:23:52', '31.00', 3, 41),
(1129, '2024-05-13 19:23:53', '31.00', 2, 41),
(1130, '2024-05-13 19:23:53', '32.00', 3, 41),
(1131, '2024-05-13 19:23:54', '32.00', 2, 41),
(1132, '2024-05-13 19:23:54', '33.00', 3, 41),
(1133, '2024-05-13 19:23:55', '33.00', 2, 41),
(1134, '2024-05-13 19:23:55', '34.00', 3, 41),
(1135, '2024-05-13 19:23:56', '34.00', 2, 41),
(1136, '2024-05-13 19:23:56', '35.00', 3, 41),
(1137, '2024-05-13 19:23:57', '35.00', 2, 41),
(1138, '2024-05-13 19:23:57', '36.00', 3, 41),
(1139, '2024-05-13 19:23:58', '36.00', 2, 41),
(1140, '2024-05-13 19:23:58', '37.00', 3, 41),
(1141, '2024-05-13 19:23:59', '37.00', 2, 41),
(1142, '2024-05-13 19:23:59', '38.00', 3, 41),
(1143, '2024-05-13 19:24:00', '38.00', 2, 41),
(1144, '2024-05-13 19:24:00', '39.00', 3, 41),
(1145, '2024-05-13 19:24:01', '39.00', 2, 41),
(1146, '2024-05-13 19:24:01', '40.00', 3, 41),
(1147, '2024-05-13 19:24:02', '40.00', 2, 41),
(1148, '2024-05-13 19:24:02', '41.00', 3, 41),
(1149, '2024-05-13 19:24:03', '41.00', 2, 41),
(1150, '2024-05-13 19:24:03', '42.00', 3, 41),
(1151, '2024-05-13 19:24:04', '42.00', 2, 41),
(1152, '2024-05-13 19:24:04', '43.00', 3, 41),
(1153, '2024-05-13 19:24:05', '43.00', 2, 41),
(1154, '2024-05-13 19:24:05', '44.00', 3, 41),
(1155, '2024-05-13 19:24:06', '44.00', 2, 41),
(1156, '2024-05-13 19:24:06', '45.00', 3, 41),
(1157, '2024-05-13 19:24:07', '45.00', 2, 41),
(1158, '2024-05-13 19:24:07', '46.00', 3, 41),
(1159, '2024-05-13 19:24:08', '46.00', 2, 41),
(1160, '2024-05-13 19:24:08', '47.00', 3, 41),
(1161, '2024-05-13 19:24:09', '47.00', 2, 41),
(1162, '2024-05-13 19:24:09', '48.00', 3, 41),
(1163, '2024-05-13 19:24:10', '48.00', 2, 41),
(1164, '2024-05-13 19:24:10', '49.00', 3, 41),
(1165, '2024-05-13 19:24:11', '49.00', 2, 41),
(1166, '2024-05-13 19:24:11', '50.00', 3, 41),
(1167, '2024-05-13 19:24:12', '50.00', 2, 41),
(1168, '2024-05-13 19:24:12', '51.00', 3, 41),
(1169, '2024-05-13 19:24:13', '49.00', 2, 41),
(1170, '2024-05-13 19:24:13', '50.00', 3, 41),
(1171, '2024-05-13 19:24:14', '48.00', 2, 41),
(1172, '2024-05-13 19:24:14', '49.00', 3, 41),
(1173, '2024-05-13 19:24:15', '47.00', 2, 41),
(1174, '2024-05-13 19:24:15', '48.00', 3, 41);

--
-- Triggers `medicoestemperatura`
--
DROP TRIGGER IF EXISTS `MedicoesTemperaturaInsertBefore`;
DELIMITER $$
CREATE TRIGGER `MedicoesTemperaturaInsertBefore` BEFORE INSERT ON `medicoestemperatura` FOR EACH ROW BEGIN

	DECLARE idExperiencia INT;
    CALL ObterExperienciaADecorrer(idExperiencia);
    
    SET new.IDExperiencia = idExperiencia;
    
    IF NOT EXISTS (SELECT * FROM sensor WHERE IDSensor = new.Sensor AND IDTipoSensor = (SELECT t.IDTipoSensor FROM tiposensor t WHERE t.Designacao = 'Temperatura') AND IsActive = TRUE) THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Sensor não reconhecivel!';
    ELSE
    	SET new.Sensor = (SELECT s.IDSensor FROM sensor s WHERE s.IDSensor = new.Sensor AND IDTipoSensor = (SELECT t.IDTipoSensor FROM tiposensor t WHERE t.Designacao = 'Temperatura') AND IsActive = TRUE);
    END IF;

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `parametroadicional`
--

DROP TABLE IF EXISTS `parametroadicional`;
CREATE TABLE IF NOT EXISTS `parametroadicional` (
  `IDParâmetro` int(11) NOT NULL AUTO_INCREMENT,
  `NrRegistosOutlierTemperatura` int(11) NOT NULL DEFAULT 25,
  `NrRegistosAlertaTemperatura` int(11) NOT NULL DEFAULT 15,
  `ControloSpamTemperatura` int(11) NOT NULL DEFAULT 30,
  `ControloSpamMovimentos` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`IDParâmetro`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `parametroadicional`
--

INSERT INTO `parametroadicional` (`IDParâmetro`, `NrRegistosOutlierTemperatura`, `NrRegistosAlertaTemperatura`, `ControloSpamTemperatura`, `ControloSpamMovimentos`) VALUES
(1, 25, 15, 30, 0);

--
-- Triggers `parametroadicional`
--
DROP TRIGGER IF EXISTS `ParametroAdicionalUpdateBefore`;
DELIMITER $$
CREATE TRIGGER `ParametroAdicionalUpdateBefore` BEFORE UPDATE ON `parametroadicional` FOR EACH ROW BEGIN

	DECLARE idExperiencia INT;
    CALL ObterExperienciaADecorrer(idExperiencia);
    
	IF idExperiencia IS NOT NULL THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Não pode editar os parametros enquanto uma experiencia está a decorrer!';
    END IF;
    
    IF new.NrRegistosOutlierTemperatura <= 0 THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'O numero de registos para deteção de outliers de temperatura não pode ser inferior ou igual a 0!';
    END IF;
    
    IF new.NrRegistosAlertaTemperatura <= 0 THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'O numero de registos para deteção de alertas de temperatura não pode ser inferior ou igual a 0!';
    END IF;
    
    IF new.ControloSpamTemperatura < 0 THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Os segundos para controlo de spam de temperatura não podem ser inferiores a 0!';
    END IF;
    
    IF new.ControloSpamMovimentos < 0 THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Os segundos para controlo de spam de temperatura não podem ser inferiores a 0!';
    END IF;

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `sensor`
--

DROP TABLE IF EXISTS `sensor`;
CREATE TABLE IF NOT EXISTS `sensor` (
  `IDSensor` int(11) NOT NULL AUTO_INCREMENT,
  `Nome` varchar(50) NOT NULL,
  `IDTipoSensor` int(11) NOT NULL,
  `IsActive` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`IDSensor`),
  KEY `IDTipoSensor` (`IDTipoSensor`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `sensor`
--

INSERT INTO `sensor` (`IDSensor`, `Nome`, `IDTipoSensor`, `IsActive`) VALUES
(1, 'Not Defined', 1, 1),
(2, '1', 2, 1),
(3, '2', 2, 1);

-- --------------------------------------------------------

--
-- Table structure for table `tiposensor`
--

DROP TABLE IF EXISTS `tiposensor`;
CREATE TABLE IF NOT EXISTS `tiposensor` (
  `IDTipoSensor` int(11) NOT NULL AUTO_INCREMENT,
  `Designacao` varchar(50) NOT NULL,
  PRIMARY KEY (`IDTipoSensor`),
  UNIQUE KEY `Designacao` (`Designacao`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `tiposensor`
--

INSERT INTO `tiposensor` (`IDTipoSensor`, `Designacao`) VALUES
(3, 'Movimento'),
(1, 'Not Defined'),
(2, 'Temperatura');

--
-- Triggers `tiposensor`
--
DROP TRIGGER IF EXISTS `TipoSensorInsertBefore`;
DELIMITER $$
CREATE TRIGGER `TipoSensorInsertBefore` BEFORE INSERT ON `tiposensor` FOR EACH ROW BEGIN

	IF EXISTS (SELECT * FROM tiposensor t WHERE t.Designacao = new.Designacao) THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Está a tentar inserir um tipo de sensor que já existe!';
    END IF;

END
$$
DELIMITER ;
DROP TRIGGER IF EXISTS `TipoSensorUpdateBefore`;
DELIMITER $$
CREATE TRIGGER `TipoSensorUpdateBefore` BEFORE UPDATE ON `tiposensor` FOR EACH ROW BEGIN

	IF EXISTS (SELECT * FROM tiposensor t WHERE t.Designacao = new.Designacao) AND new.Designacao <> old.Designacao THEN
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Já existe o tipo de sensor!';
    END IF;

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `utilizador`
--

DROP TABLE IF EXISTS `utilizador`;
CREATE TABLE IF NOT EXISTS `utilizador` (
  `Email` varchar(200) NOT NULL,
  `Nome` varchar(100) NOT NULL,
  `Telefone` varchar(12) DEFAULT NULL,
  `RemocaoLogica` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`Email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `utilizador`
--

INSERT INTO `utilizador` (`Email`, `Nome`, `Telefone`, `RemocaoLogica`) VALUES
('admin@iscte.pt', 'Admin', '921345678', 0),
('fatima@iscte.pt', 'Fatima', '918649728', 0),
('pedro@iscte.pt', 'Pedro', '912345678', 0),
('system@iscte.pt', 'System', NULL, 0);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_expadecorrer`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `v_expadecorrer`;
CREATE TABLE IF NOT EXISTS `v_expadecorrer` (
`IDExperiencia` int(11)
,`Descrição` text
,`DataHoraCriaçãoExperiência` datetime
,`NúmeroRatos` int(11)
,`LimiteRatosSala` int(11)
,`SegundosSemMovimento` int(11)
,`TemperaturaMinima` decimal(4,2)
,`TemperaturaMaxima` decimal(4,2)
,`TemperaturaAvisoMaximo` decimal(4,2)
,`TemperaturaAvisoMinimo` decimal(4,2)
,`DataHoraInicioExperiência` datetime
,`DataHoraFimExperiência` datetime
,`Investigador` varchar(200)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_utilizador`
-- (See below for the actual view)
--
DROP VIEW IF EXISTS `v_utilizador`;
CREATE TABLE IF NOT EXISTS `v_utilizador` (
`Email` varchar(200)
,`Nome` varchar(100)
,`Telefone` varchar(12)
,`RemocaoLogica` tinyint(1)
);

-- --------------------------------------------------------

--
-- Structure for view `v_expadecorrer`
--
DROP TABLE IF EXISTS `v_expadecorrer`;

DROP VIEW IF EXISTS `v_expadecorrer`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_expadecorrer`  AS SELECT `e`.`IDExperiencia` AS `IDExperiencia`, `e`.`Descrição` AS `Descrição`, `e`.`DataHoraCriaçãoExperiência` AS `DataHoraCriaçãoExperiência`, `e`.`NúmeroRatos` AS `NúmeroRatos`, `e`.`LimiteRatosSala` AS `LimiteRatosSala`, `e`.`SegundosSemMovimento` AS `SegundosSemMovimento`, `e`.`TemperaturaMinima` AS `TemperaturaMinima`, `e`.`TemperaturaMaxima` AS `TemperaturaMaxima`, `e`.`TemperaturaAvisoMaximo` AS `TemperaturaAvisoMaximo`, `e`.`TemperaturaAvisoMinimo` AS `TemperaturaAvisoMinimo`, `e`.`DataHoraInicioExperiência` AS `DataHoraInicioExperiência`, `e`.`DataHoraFimExperiência` AS `DataHoraFimExperiência`, `e`.`Investigador` AS `Investigador` FROM `experiencia` AS `e` WHERE `e`.`DataHoraInicioExperiência` is not null AND `e`.`DataHoraFimExperiência` is null  ;

-- --------------------------------------------------------

--
-- Structure for view `v_utilizador`
--
DROP TABLE IF EXISTS `v_utilizador`;

DROP VIEW IF EXISTS `v_utilizador`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_utilizador`  AS SELECT `u`.`Email` AS `Email`, `u`.`Nome` AS `Nome`, `u`.`Telefone` AS `Telefone`, `u`.`RemocaoLogica` AS `RemocaoLogica` FROM `utilizador` AS `u` WHERE `u`.`Email` = substring_index(user(),'@',2)  ;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `alerta`
--
ALTER TABLE `alerta`
  ADD CONSTRAINT `ExperienciaFK` FOREIGN KEY (`IDExperiencia`) REFERENCES `experiencia` (`IDExperiencia`) ON UPDATE CASCADE;

--
-- Constraints for table `experiencia`
--
ALTER TABLE `experiencia`
  ADD CONSTRAINT `experiencia_ibfk_1` FOREIGN KEY (`Investigador`) REFERENCES `utilizador` (`Email`) ON UPDATE CASCADE;

--
-- Constraints for table `medicoesnaoconformes`
--
ALTER TABLE `medicoesnaoconformes`
  ADD CONSTRAINT `medicoesnaoconformes_ibfk_1` FOREIGN KEY (`IDExperiencia`) REFERENCES `experiencia` (`IDExperiencia`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `medicoespassagem`
--
ALTER TABLE `medicoespassagem`
  ADD CONSTRAINT `medicoespassagem_ibfk_1` FOREIGN KEY (`IDExperiencia`) REFERENCES `experiencia` (`IDExperiencia`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `medicoessala`
--
ALTER TABLE `medicoessala`
  ADD CONSTRAINT `medicoessala_ibfk_1` FOREIGN KEY (`IDExperiencia`) REFERENCES `experiencia` (`IDExperiencia`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `medicoestemperatura`
--
ALTER TABLE `medicoestemperatura`
  ADD CONSTRAINT `medicoestemperatura_ibfk_1` FOREIGN KEY (`IDExperiencia`) REFERENCES `experiencia` (`IDExperiencia`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `medicoestemperatura_ibfk_2` FOREIGN KEY (`Sensor`) REFERENCES `sensor` (`IDSensor`) ON UPDATE CASCADE;

--
-- Constraints for table `sensor`
--
ALTER TABLE `sensor`
  ADD CONSTRAINT `sensor_ibfk_1` FOREIGN KEY (`IDTipoSensor`) REFERENCES `tiposensor` (`IDTipoSensor`) ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
