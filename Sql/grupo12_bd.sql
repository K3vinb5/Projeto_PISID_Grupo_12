-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 14, 2024 at 12:55 AM
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
) ENGINE=InnoDB AUTO_INCREMENT=86 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

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
(29, '2024-05-13 19:21:14', 2, NULL, NULL, 'Capacidade da sala', 'Limite de ratos atingido!', NULL),
(43, '2024-05-13 22:50:38', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 41),
(44, '2024-05-13 23:10:48', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 41),
(45, '2024-05-13 23:22:55', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 41),
(46, '2024-05-13 23:23:00', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 41),
(47, '2024-05-13 23:23:01', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 41),
(48, '2024-05-13 23:23:17', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 41),
(49, '2024-05-13 23:23:18', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 41),
(50, '2024-05-13 23:23:19', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 41),
(51, '2024-05-13 23:23:33', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 41),
(52, '2024-05-13 23:23:41', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 41),
(53, '2024-05-13 23:23:45', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 41),
(54, '2024-05-13 23:24:07', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 41),
(55, '2024-05-13 23:24:26', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 41),
(56, '2024-05-13 23:24:32', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 41),
(57, '2024-05-13 23:24:32', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado! 50', 41),
(58, '2024-05-13 23:24:37', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 41),
(59, '2024-05-13 23:24:37', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado! 50', 41),
(60, '2024-05-13 23:24:45', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 41),
(61, '2024-05-13 23:24:45', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado! 50', 41),
(62, '2024-05-13 23:24:49', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 41),
(63, '2024-05-13 23:24:49', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado! 50', 41),
(64, '2024-05-13 23:24:59', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 41),
(65, '2024-05-13 23:24:59', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado! 50', 41),
(66, '2024-05-13 23:25:09', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 41),
(67, '2024-05-13 23:25:09', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado! 50', 41),
(68, '2024-05-13 23:25:19', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 41),
(69, '2024-05-13 23:25:19', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado! 50', 41),
(70, '2024-05-13 23:25:28', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 41),
(71, '2024-05-13 23:25:28', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado! 50', 41),
(72, '2024-05-13 23:25:47', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 41),
(73, '2024-05-13 23:25:47', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado! 50', 41),
(74, '2024-05-13 23:25:52', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 41),
(75, '2024-05-13 23:25:52', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado! 50', 41),
(76, '2024-05-13 23:26:11', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 41),
(77, '2024-05-13 23:26:11', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado! 50', 41),
(78, '2024-05-13 23:26:13', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 41),
(79, '2024-05-13 23:26:13', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado! 50', 41),
(80, '2024-05-13 23:26:19', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 41),
(81, '2024-05-13 23:26:19', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado! 50', 41),
(82, '2024-05-13 23:26:23', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 41),
(83, '2024-05-13 23:26:23', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado! 50', 41),
(84, '2024-05-13 23:26:35', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado!', 41),
(85, '2024-05-13 23:26:35', 1, NULL, NULL, 'Capacidade da sala', 'Limite de ratos ultrapassado! 50', 41);

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
(41, 'Mais outra exp', '2024-05-13 19:21:05', 80, 50, 100, '-25.00', '75.00', '74.00', '-24.00', '2024-05-13 23:37:37', '2024-05-13 23:48:22', 'pedro@iscte.pt');

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
) ENGINE=InnoDB AUTO_INCREMENT=252 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `medicoesnaoconformes`
--

INSERT INTO `medicoesnaoconformes` (`IDMedicao`, `IDExperiencia`, `RegistoRecebido`, `TipoMedicao`, `TipoDado`) VALUES
(1, NULL, '{\"Hora\": \"2024-05-13 22:49:26.329222\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(2, NULL, '{\"Hora\": \"2024-05-13 22:49:29.329825\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(3, NULL, '{\"Hora\": \"2024-05-13 22:49:35.330699\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(4, NULL, '{\"Hora\": \"2024-05-13 22:49:36.321736\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(5, NULL, '{\"Hora\": \"2024-05-13 22:49:38.331194\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(6, NULL, '{\"Hora\": \"2024-05-13 22:49:41.331721\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(7, NULL, '{\"Hora\": \"2024-05-13 22:49:43.327049\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(8, NULL, '{\"Hora\": \"2024-05-13 22:49:44.332206\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(9, NULL, '{\"Hora\": \"2024-05-13 22:49:45.329383\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(10, NULL, '{\"Hora\": \"2024-05-13 22:49:47.332207\", \"SalaOrigem\": \"3\", \"SalaDestino\": \"10\"}', 'Movimento', 'Dado Errado'),
(11, NULL, '{\"Hora\": \"2024-05-13 22:49:49.329835\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(12, NULL, '{\"Hora\": \"2024-05-13 22:49:53.334659\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(13, NULL, '{\"Hora\": \"2024-05-13 22:50:02.336256\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(14, NULL, '{\"Hora\": \"2024-05-13 22:50:04.332982\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(15, NULL, '{\"Hora\": \"2024-05-13 22:50:05.336657\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(16, NULL, '{\"Hora\": \"2024-05-13 22:50:11.338125\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(17, NULL, '{\"Hora\": \"2024-05-13 22:50:12.333788\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(18, NULL, '{\"Hora\": \"2024-05-13 22:50:17.339205\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(19, NULL, '{\"Hora\": \"2024-05-13 22:50:20.339729\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(20, NULL, '{\"Hora\": \"2024-05-13 22:50:35.342326\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(21, NULL, '{\"Hora\": \"2024-05-13 22:50:38.335191\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(22, NULL, '{\"Hora\": \"2024-05-13 22:50:40.340147\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(23, NULL, '{\"Hora\": \"2024-05-13 22:50:41.344348\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(24, NULL, '{\"Hora\": \"2024-05-13 22:50:47.335743\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(25, NULL, '{\"Hora\": \"2024-05-13 22:50:51.339412\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(26, NULL, '{\"Hora\": \"2024-05-13 22:50:55.340335\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(27, NULL, '{\"Hora\": \"2024-05-13 22:50:56.346491\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(28, NULL, '{\"Hora\": \"2024-05-13 22:51:07.345580\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(29, NULL, '{\"Hora\": \"2024-05-13 22:51:09.343419\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(30, NULL, '{\"Hora\": \"2024-05-13 22:51:10.343078\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(31, NULL, '{\"Hora\": \"2024-05-13 22:51:10.345591\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(32, NULL, '{\"Hora\": \"2024-05-13 22:51:11.348654\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(33, NULL, '{\"Hora\": \"2024-05-13 22:51:14.349313\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(34, NULL, '{\"Hora\": \"2024-05-13 22:51:17.349894\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(35, NULL, '{\"Hora\": \"2024-05-13 22:51:18.338055\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(36, NULL, '{\"Hora\": \"2024-05-13 22:51:20.350403\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(37, NULL, '{\"Hora\": \"2024-05-13 22:51:22.337615\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(38, NULL, '{\"Hora\": \"2024-05-13 22:51:22.341628\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(39, NULL, '{\"Hora\": \"2024-05-13 22:51:22.349133\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(40, NULL, '{\"Hora\": \"2024-05-13 22:51:24.348974\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(41, NULL, '{\"Hora\": \"2024-05-13 22:51:26.351101\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(42, NULL, '{\"Hora\": \"2024-05-13 22:51:28.347819\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(43, NULL, '{\"Hora\": \"2024-05-13 22:51:29.342983\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(44, NULL, '{\"Hora\": \"2024-05-13 22:51:35.344489\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(45, NULL, '{\"Hora\": \"2024-05-13 22:51:36.344552\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(46, NULL, '{\"Hora\": \"2024-05-13 22:51:38.353400\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(47, NULL, '{\"Hora\": \"2024-05-13 22:51:39.349448\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(48, NULL, '{\"Hora\": \"2024-05-13 22:51:44.354175\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(49, NULL, '{\"Hora\": \"2024-05-13 22:51:50.354838\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(50, NULL, '{\"Hora\": \"2024-05-13 22:51:53.343328\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(51, NULL, '{\"Hora\": \"2024-05-13 22:51:56.357247\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(52, NULL, '{\"Hora\": \"2024-05-13 22:52:01.353457\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(53, NULL, '{\"Hora\": \"2024-05-13 22:52:04.354854\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(54, NULL, '{\"Hora\": \"2024-05-13 22:52:05.359534\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(55, NULL, '{\"Hora\": \"2024-05-13 22:52:06.354205\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(56, NULL, '{\"Hora\": \"2024-05-13 22:52:11.354967\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(57, NULL, '{\"Hora\": \"2024-05-13 22:52:12.349022\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(58, NULL, '{\"Hora\": \"2024-05-13 22:52:16.357577\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(59, NULL, '{\"Hora\": \"2024-05-13 22:52:17.351237\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(60, NULL, '{\"Hora\": \"2024-05-13 22:52:20.364158\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(61, NULL, '{\"Hora\": \"2024-05-13 22:52:23.364651\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(62, NULL, '{\"Hora\": \"2024-05-13 22:52:24.347191\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(63, NULL, '{\"Hora\": \"2024-05-13 22:52:25.359752\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(64, NULL, '{\"Hora\": \"2024-05-13 22:52:26.365318\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(65, NULL, '{\"Hora\": \"2024-05-13 22:52:27.355368\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(66, NULL, '{\"Hora\": \"2024-05-13 22:52:28.358047\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(67, NULL, '{\"Hora\": \"2024-05-13 22:52:32.357114\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(68, NULL, '{\"Hora\": \"2024-05-13 22:52:32.366118\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(69, NULL, '{\"Hora\": \"2024-05-13 22:52:36.357268\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(70, NULL, '{\"Hora\": \"2024-05-13 22:52:36.358774\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(71, NULL, '{\"Hora\": \"2024-05-13 22:52:41.367438\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(72, NULL, '{\"Hora\": \"2024-05-13 22:52:44.367807\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(73, NULL, '{\"Hora\": \"2024-05-13 22:52:52.392758\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(74, NULL, '{\"Hora\": \"2024-05-13 22:52:54.383979\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(75, NULL, '{\"Hora\": \"2024-05-13 22:52:58.477800\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(76, NULL, '{\"Hora\": \"2024-05-13 22:53:04.493857\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(77, NULL, '{\"Hora\": \"2024-05-13 22:53:06.588404\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(78, NULL, '{\"Hora\": \"2024-05-13 22:53:10.647696\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(79, NULL, '{\"Hora\": \"2024-05-13 22:53:15.655877\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(80, NULL, '{\"Hora\": \"2024-05-13 22:53:19.720022\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(81, NULL, '{\"Hora\": \"2024-05-13 22:53:33.680102\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(82, NULL, '{\"Hora\": \"2024-05-13 22:54:09.340936\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(83, NULL, '{\"Hora\": \"2024-05-13 22:54:44.488777\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(84, 41, '{\"Solucao\": \"0-15-4-0-8-1-0-16-0-36\"}', 'Movimento', 'Dado Errado'),
(85, 41, '{\"Hora\": \"2000-01-01 00:00:00\", \"SalaOrigem\": \"0\", \"SalaDestino\": \"0\"}', 'Movimento', 'Dado Errado'),
(86, NULL, '{\"Hora\": \"2024-05-13 22:55:00.571295\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(87, NULL, '{\"Hora\": \"2024-05-13 22:55:03.572498\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(88, NULL, '{\"Hora\": \"2024-05-13 22:55:09.573799\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(89, NULL, '{\"Hora\": \"2024-05-13 22:55:18.577091\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(90, NULL, '{\"Hora\": \"2024-05-13 22:55:24.578185\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(91, NULL, '{\"Hora\": \"2024-05-13 22:55:39.581228\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(92, NULL, '{\"Hora\": \"2024-05-13 22:55:42.581737\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(93, NULL, '{\"Hora\": \"2024-05-13 22:55:46.573867\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(94, NULL, '{\"Hora\": \"2024-05-13 22:55:57.595716\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(95, NULL, '{\"Hora\": \"2024-05-13 22:55:59.580416\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(96, NULL, '{\"Hora\": \"2024-05-13 22:56:00.596579\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(97, NULL, '{\"Hora\": \"2024-05-13 22:57:26.620592\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(98, NULL, '{\"Hora\": \"2024-05-13 22:57:27.611644\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(99, NULL, '{\"Hora\": \"2024-05-13 22:57:33.604687\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(100, NULL, '{\"Hora\": \"2024-05-13 22:57:33.612703\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(101, NULL, '{\"Hora\": \"2024-05-13 22:57:35.604284\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(102, NULL, '{\"Hora\": \"2024-05-13 22:57:35.605301\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(103, NULL, '{\"Hora\": \"2024-05-13 22:57:36.612994\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(104, NULL, '{\"Hora\": \"2024-05-13 22:57:39.600402\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(105, NULL, '{\"Hora\": \"2024-05-13 22:57:40.608467\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(106, NULL, '{\"Hora\": \"2024-05-13 22:57:40.610990\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(107, NULL, '{\"Hora\": \"2024-05-13 22:57:42.621742\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(108, NULL, '{\"Hora\": \"2024-05-13 22:57:44.604474\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(109, NULL, '{\"Hora\": \"2024-05-13 22:57:45.615791\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(110, NULL, '{\"Hora\": \"2024-05-13 22:57:49.612212\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(111, NULL, '{\"Hora\": \"2024-05-13 22:57:52.589891\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(112, NULL, '{\"Hora\": \"2024-05-13 22:57:52.623937\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(113, NULL, '{\"Hora\": \"2024-05-13 22:57:59.606174\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(114, NULL, '{\"Hora\": \"2024-05-13 22:58:01.605874\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(115, NULL, '{\"Hora\": \"2024-05-13 22:58:06.619507\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(116, NULL, '{\"Hora\": \"2024-05-13 22:58:09.620306\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(117, NULL, '{\"Hora\": \"2024-05-13 22:58:18.627601\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(118, NULL, '{\"Hora\": \"2024-05-13 22:58:21.622963\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(119, NULL, '{\"Hora\": \"2024-05-13 22:58:24.624337\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(120, NULL, '{\"Hora\": \"2024-05-13 22:58:27.624857\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(121, NULL, '{\"Hora\": \"2024-05-13 22:58:28.620428\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(122, NULL, '{\"Hora\": \"2024-05-13 22:58:29.620594\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(123, NULL, '{\"Hora\": \"2024-05-13 22:58:30.625265\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(124, NULL, '{\"Hora\": \"2024-05-13 22:58:32.608980\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(125, NULL, '{\"Hora\": \"2024-05-13 22:58:35.622138\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(126, NULL, '{\"Hora\": \"2024-05-13 22:58:37.620363\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(127, NULL, '{\"Hora\": \"2024-05-13 22:58:38.615411\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(128, NULL, '{\"Hora\": \"2024-05-13 22:58:42.611844\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(129, NULL, '{\"Hora\": \"2024-05-13 22:58:46.622887\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(130, NULL, '{\"Hora\": \"2024-05-13 22:58:48.629098\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(131, NULL, '{\"Hora\": \"2024-05-13 22:59:04.645954\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(132, NULL, '{\"Hora\": \"2024-05-13 22:59:09.749365\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(133, NULL, '{\"Hora\": \"2024-05-13 22:59:19.857515\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(134, NULL, '{\"Hora\": \"2024-05-13 22:59:32.803314\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(135, NULL, '{\"Hora\": \"2024-05-13 22:59:33.912712\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(136, NULL, '{\"Hora\": \"2024-05-13 23:00:05.325919\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(137, NULL, '{\"Hora\": \"2024-05-13 23:00:24.357536\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(138, NULL, '{\"Hora\": \"2024-05-13 23:00:38.858666\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(139, 41, '{\"Solucao\": \"0-12-4-3-9-4-19-2-9-18\"}', 'Movimento', 'Dado Errado'),
(140, 41, '{\"Hora\": \"2000-01-01 00:00:00\", \"SalaOrigem\": \"0\", \"SalaDestino\": \"0\"}', 'Movimento', 'Dado Errado'),
(141, 41, '{\"Hora\": \"2024-05-13 23:00:51.940590\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(142, 41, '{\"Hora\": \"2024-05-13 23:00:54.942294\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(143, 41, '{\"Hora\": \"2024-05-13 23:00:57.942998\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(144, 41, '{\"Hora\": \"2024-05-13 23:01:00.943701\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(145, 41, '{\"Hora\": \"2024-05-13 23:01:03.944414\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(146, 41, '{\"Hora\": \"2024-05-13 23:01:06.944994\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(147, 41, '{\"Hora\": \"2024-05-13 23:01:12.946286\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(148, 41, '{\"Hora\": \"2024-05-13 23:01:15.947893\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(149, 41, '{\"Hora\": \"2024-05-13 23:01:24.949794\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(150, 41, '{\"Hora\": \"2024-05-13 23:01:27.951382\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(151, 41, '{\"Hora\": \"2024-05-13 23:01:30.951961\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(152, 41, '{\"Hora\": \"2024-05-13 23:01:33.952445\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(153, 41, '{\"Hora\": \"2024-05-13 23:01:36.952934\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(154, 41, '{\"Hora\": \"2024-05-13 23:01:48.955543\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(155, 41, '{\"Hora\": \"2024-05-13 23:01:51.956513\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(156, 41, '{\"Hora\": \"2024-05-13 23:01:54.957102\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(157, 41, '{\"Hora\": \"2024-05-13 23:01:56.953416\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(158, 41, '{\"Hora\": \"2024-05-13 23:01:59.953892\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(159, 41, '{\"Hora\": \"2024-05-13 23:02:00.958057\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(160, 41, '{\"Hora\": \"2024-05-13 23:02:09.960376\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(161, 41, '{\"Hora\": \"2024-05-13 23:02:12.960728\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(162, 41, '{\"Hora\": \"2024-05-13 23:02:14.951938\", \"SalaOrigem\": \"3\", \"SalaDestino\": \"10\"}', 'Movimento', 'Dado Errado'),
(163, 41, '{\"Hora\": \"2024-05-13 23:02:15.961480\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(164, 41, '{\"Hora\": \"2024-05-13 23:02:21.962366\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(165, 41, '{\"Hora\": \"2024-05-13 23:02:24.962956\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(166, 41, '{\"Hora\": \"2024-05-13 23:02:27.963456\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(167, 41, '{\"Hora\": \"2024-05-13 23:02:33.964556\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(168, 41, '{\"Hora\": \"2024-05-13 23:02:37.948956\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(169, 41, '{\"Hora\": \"2024-05-13 23:02:42.965921\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(170, 41, '{\"Hora\": \"2024-05-13 23:02:43.956454\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(171, 41, '{\"Hora\": \"2024-05-13 23:02:45.966390\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(172, 41, '{\"Hora\": \"2024-05-13 23:02:50.966199\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(173, 41, '{\"Hora\": \"2024-05-13 23:02:51.968857\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(174, 41, '{\"Hora\": \"2024-05-13 23:02:57.970062\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(175, 41, '{\"Hora\": \"2024-05-13 23:03:03.972148\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(176, 41, '{\"Hora\": \"2024-05-13 23:03:09.974113\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(177, 41, '{\"Hora\": \"2024-05-13 23:03:15.975208\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(178, 41, '{\"Hora\": \"2024-05-13 23:03:21.968656\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(179, 41, '{\"Hora\": \"2024-05-13 23:03:21.977170\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(180, 41, '{\"Hora\": \"2024-05-13 23:03:24.977770\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(181, 41, '{\"Hora\": \"2024-05-13 23:03:27.978476\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(182, 41, '{\"Hora\": \"2024-05-13 23:03:30.978963\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(183, 41, '{\"Hora\": \"2024-05-13 23:03:38.971621\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(184, 41, '{\"Hora\": \"2024-05-13 23:03:39.981300\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(185, 41, '{\"Hora\": \"2024-05-13 23:03:42.981769\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(186, 41, '{\"Hora\": \"2024-05-13 23:03:45.982358\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(187, 41, '{\"Hora\": \"2024-05-13 23:03:47.970549\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(188, 41, '{\"Hora\": \"2024-05-13 23:03:48.982738\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(189, 41, '{\"Hora\": \"2024-05-13 23:03:51.983087\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(190, 41, '{\"Hora\": \"2024-05-13 23:03:54.983816\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(191, 41, '{\"Hora\": \"2024-05-13 23:04:03.986487\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(192, 41, '{\"Hora\": \"2024-05-13 23:04:12.988063\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(193, 41, '{\"Hora\": \"2024-05-13 23:04:13.972101\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(194, 41, '{\"Hora\": \"2024-05-13 23:04:15.989534\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(195, 41, '{\"Hora\": \"2024-05-13 23:04:18.990011\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(196, 41, '{\"Hora\": \"2024-05-13 23:04:21.990490\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(197, 41, '{\"Hora\": \"2024-05-13 23:04:27.991694\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(198, 41, '{\"Hora\": \"2024-05-13 23:04:30.992304\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(199, 41, '{\"Hora\": \"2024-05-13 23:04:33.993009\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(200, 41, '{\"Hora\": \"2024-05-13 23:04:36.993712\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(201, 41, '{\"Hora\": \"2024-05-13 23:04:39.994297\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(202, 41, '{\"Hora\": \"2024-05-13 23:04:42.995004\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(203, 41, '{\"Hora\": \"2024-05-13 23:04:45.995720\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(204, 41, '{\"Hora\": \"2024-05-13 23:04:48.996319\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(205, 41, '{\"Hora\": \"2024-05-13 23:05:08.184917\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(206, NULL, '{\"Solucao\": \"0-0-26-14-1-15-13-0-0-11\"}', 'Movimento', 'Dado Errado'),
(207, NULL, '{\"Hora\": \"2000-01-01 00:00:00\", \"SalaOrigem\": \"0\", \"SalaDestino\": \"0\"}', 'Movimento', 'Dado Errado'),
(208, NULL, '{\"Hora\": \"2024-05-13 23:06:17.795238\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(209, NULL, '{\"Hora\": \"2024-05-13 23:06:26.798869\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(210, NULL, '{\"Hora\": \"2024-05-13 23:06:29.799570\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(211, NULL, '{\"Hora\": \"2024-05-13 23:06:32.800156\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(212, NULL, '{\"Hora\": \"2024-05-13 23:06:35.800854\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(213, NULL, '{\"Hora\": \"2024-05-13 23:06:38.801326\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(214, NULL, '{\"Hora\": \"2024-05-13 23:06:40.795753\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(215, NULL, '{\"Hora\": \"2024-05-13 23:06:41.801910\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(216, NULL, '{\"Hora\": \"2024-05-13 23:06:44.802510\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(217, NULL, '{\"Hora\": \"2024-05-13 23:06:53.805195\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(218, NULL, '{\"Hora\": \"2024-05-13 23:06:55.802506\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(219, NULL, '{\"Hora\": \"2024-05-13 23:06:56.805683\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(220, NULL, '{\"Hora\": \"2024-05-13 23:06:59.806148\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(221, NULL, '{\"Hora\": \"2024-05-13 23:07:04.802668\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(222, NULL, '{\"Hora\": \"2024-05-13 23:07:05.807359\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(223, NULL, '{\"Hora\": \"2024-05-13 23:07:06.797397\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(224, NULL, '{\"Hora\": \"2024-05-13 23:07:06.804915\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(225, NULL, '{\"Hora\": \"2024-05-13 23:07:08.807750\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(226, NULL, '{\"Hora\": \"2024-05-13 23:07:11.808353\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(227, NULL, '{\"Hora\": \"2024-05-13 23:07:16.804871\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(228, NULL, '{\"Hora\": \"2024-05-13 23:07:20.810943\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(229, NULL, '{\"Hora\": \"2024-05-13 23:07:23.807821\", \"SalaOrigem\": \"3\", \"SalaDestino\": \"10\"}', 'Movimento', 'Dado Errado'),
(230, NULL, '{\"Hora\": \"2024-05-13 23:07:23.811326\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(231, NULL, '{\"Hora\": \"2024-05-13 23:07:26.813408\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(232, NULL, '{\"Hora\": \"2024-05-13 23:07:29.813884\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(233, NULL, '{\"Hora\": \"2024-05-13 23:07:30.804044\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(234, NULL, '{\"Hora\": \"2024-05-13 23:07:32.806498\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(235, NULL, '{\"Hora\": \"2024-05-13 23:07:32.814500\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(236, NULL, '{\"Hora\": \"2024-05-13 23:07:37.799246\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(237, NULL, '{\"Hora\": \"2024-05-13 23:07:38.815423\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(238, NULL, '{\"Hora\": \"2024-05-13 23:07:41.815949\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(239, NULL, '{\"Hora\": \"2024-05-13 23:07:45.805615\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(240, NULL, '{\"Hora\": \"2024-05-13 23:07:47.818573\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(241, NULL, '{\"Hora\": \"2024-05-13 23:07:53.820106\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(242, NULL, '{\"Hora\": \"2024-05-13 23:07:59.822856\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(243, NULL, '{\"Hora\": \"2024-05-13 23:08:00.816017\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(244, NULL, '{\"Hora\": \"2024-05-13 23:08:03.809278\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(245, NULL, '{\"Hora\": \"2024-05-13 23:08:04.818361\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(246, NULL, '{\"Hora\": \"2024-05-13 23:08:05.825027\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(247, NULL, '{\"Hora\": \"2024-05-13 23:08:06.804064\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(248, NULL, '{\"Hora\": \"2024-05-13 23:08:08.801671\", \"SalaOrigem\": \"5\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(249, NULL, '{\"Hora\": \"2024-05-13 23:08:08.826315\", \"SalaOrigem\": \"1\", \"SalaDestino\": \"3\"}', 'Movimento', 'Dado Errado'),
(250, 41, '{\"Solucao\": \"0-0-22-1-6-20-1-12-12-6\"}', 'Movimento', 'Dado Errado'),
(251, NULL, '{\"Solucao\": \"0-0-18-2-14-1-1-2-29-13\"}', 'Movimento', 'Dado Errado');

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
) ENGINE=InnoDB AUTO_INCREMENT=1944 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `medicoespassagem`
--

INSERT INTO `medicoespassagem` (`IDMedição`, `DataHora`, `SalaOrigem`, `SalaDestino`, `IDExperiencia`) VALUES
(1, '2024-05-13 22:49:23', 1, 2, NULL),
(2, '2024-05-13 22:49:24', 7, 5, NULL),
(3, '2024-05-13 22:49:24', 2, 5, NULL),
(4, '2024-05-13 22:49:26', 7, 5, NULL),
(5, '2024-05-13 22:49:26', 6, 8, NULL),
(6, '2024-05-13 22:49:26', 1, 2, NULL),
(7, '2024-05-13 22:49:27', 2, 5, NULL),
(8, '2024-05-13 22:49:27', 5, 7, NULL),
(9, '2024-05-13 22:49:27', 2, 4, NULL),
(10, '2024-05-13 22:49:29', 3, 2, NULL),
(11, '2024-05-13 22:49:30', 5, 7, NULL),
(12, '2024-05-13 22:49:30', 2, 4, NULL),
(13, '2024-05-13 22:49:31', 5, 6, NULL),
(14, '2024-05-13 22:49:32', 3, 2, NULL),
(15, '2024-05-13 22:49:33', 5, 6, NULL),
(16, '2024-05-13 22:49:33', 7, 5, NULL),
(17, '2024-05-13 22:49:34', 5, 6, NULL),
(18, '2024-05-13 22:49:35', 7, 5, NULL),
(19, '2024-05-13 22:49:35', 4, 5, NULL),
(20, '2024-05-13 22:49:35', 1, 2, NULL),
(21, '2024-05-13 22:49:36', 2, 5, NULL),
(22, '2024-05-13 22:49:38', 6, 8, NULL),
(23, '2024-05-13 22:49:38', 4, 5, NULL),
(24, '2024-05-13 22:49:38', 3, 2, NULL),
(25, '2024-05-13 22:49:39', 3, 2, NULL),
(26, '2024-05-13 22:49:39', 5, 7, NULL),
(27, '2024-05-13 22:49:39', 2, 5, NULL),
(28, '2024-05-13 22:49:39', 2, 4, NULL),
(29, '2024-05-13 22:49:40', 6, 8, NULL),
(30, '2024-05-13 22:49:41', 8, 10, NULL),
(31, '2024-05-13 22:49:41', 6, 8, NULL),
(32, '2024-05-13 22:49:41', 3, 2, NULL),
(33, '2024-05-13 22:49:42', 7, 5, NULL),
(34, '2024-05-13 22:49:42', 2, 4, NULL),
(35, '2024-05-13 22:49:44', 3, 2, NULL),
(36, '2024-05-13 22:49:45', 5, 6, NULL),
(37, '2024-05-13 22:49:45', 7, 5, NULL),
(38, '2024-05-13 22:49:45', 2, 4, NULL),
(39, '2024-05-13 22:49:46', 3, 2, NULL),
(40, '2024-05-13 22:49:47', 4, 5, NULL),
(41, '2024-05-13 22:49:47', 3, 2, NULL),
(42, '2024-05-13 22:49:48', 5, 7, NULL),
(43, '2024-05-13 22:49:48', 5, 6, NULL),
(44, '2024-05-13 22:49:48', 3, 2, NULL),
(45, '2024-05-13 22:49:48', 2, 4, NULL),
(46, '2024-05-13 22:49:49', 2, 4, NULL),
(47, '2024-05-13 22:49:50', 4, 5, NULL),
(48, '2024-05-13 22:49:50', 1, 2, NULL),
(49, '2024-05-13 22:49:52', 6, 8, NULL),
(50, '2024-05-13 22:49:52', 5, 6, NULL),
(51, '2024-05-13 22:49:52', 3, 2, NULL),
(52, '2024-05-13 22:49:53', 4, 5, NULL),
(53, '2024-05-13 22:49:53', 1, 2, NULL),
(54, '2024-05-13 22:49:54', 7, 5, NULL),
(55, '2024-05-13 22:49:54', 2, 5, NULL),
(56, '2024-05-13 22:49:54', 2, 4, NULL),
(57, '2024-05-13 22:49:55', 8, 10, NULL),
(58, '2024-05-13 22:49:55', 6, 8, NULL),
(59, '2024-05-13 22:49:56', 8, 10, NULL),
(60, '2024-05-13 22:49:56', 5, 7, NULL),
(61, '2024-05-13 22:49:56', 4, 5, NULL),
(62, '2024-05-13 22:49:56', 3, 2, NULL),
(63, '2024-05-13 22:49:57', 4, 5, NULL),
(64, '2024-05-13 22:49:57', 5, 6, NULL),
(65, '2024-05-13 22:49:57', 2, 4, NULL),
(66, '2024-05-13 22:49:59', 2, 5, NULL),
(67, '2024-05-13 22:49:59', 6, 8, NULL),
(68, '2024-05-13 22:49:59', 5, 7, NULL),
(69, '2024-05-13 22:49:59', 1, 2, NULL),
(70, '2024-05-13 22:50:00', 5, 6, NULL),
(71, '2024-05-13 22:50:00', 2, 4, NULL),
(72, '2024-05-13 22:50:01', 2, 5, NULL),
(73, '2024-05-13 22:50:02', 2, 4, NULL),
(74, '2024-05-13 22:50:02', 4, 5, NULL),
(75, '2024-05-13 22:50:02', 1, 2, NULL),
(76, '2024-05-13 22:50:03', 7, 5, NULL),
(77, '2024-05-13 22:50:04', 5, 6, NULL),
(78, '2024-05-13 22:50:04', 5, 7, NULL),
(79, '2024-05-13 22:50:04', 6, 8, NULL),
(80, '2024-05-13 22:50:05', 4, 5, NULL),
(81, '2024-05-13 22:50:05', 3, 2, NULL),
(82, '2024-05-13 22:50:06', 2, 5, NULL),
(83, '2024-05-13 22:50:06', 2, 4, NULL),
(84, '2024-05-13 22:50:07', 5, 6, NULL),
(85, '2024-05-13 22:50:07', 8, 10, NULL),
(86, '2024-05-13 22:50:07', 6, 8, NULL),
(87, '2024-05-13 22:50:07', 3, 2, NULL),
(88, '2024-05-13 22:50:08', 4, 5, NULL),
(89, '2024-05-13 22:50:08', 3, 2, NULL),
(90, '2024-05-13 22:50:09', 5, 6, NULL),
(91, '2024-05-13 22:50:10', 8, 10, NULL),
(92, '2024-05-13 22:50:10', 4, 5, NULL),
(93, '2024-05-13 22:50:11', 6, 8, NULL),
(94, '2024-05-13 22:50:11', 7, 5, NULL),
(95, '2024-05-13 22:50:11', 5, 7, NULL),
(96, '2024-05-13 22:50:11', 1, 2, NULL),
(97, '2024-05-13 22:50:12', 2, 5, NULL),
(98, '2024-05-13 22:50:13', 5, 6, NULL),
(99, '2024-05-13 22:50:14', 6, 8, NULL),
(100, '2024-05-13 22:50:14', 8, 10, NULL),
(101, '2024-05-13 22:50:14', 7, 5, NULL),
(102, '2024-05-13 22:50:14', 4, 5, NULL),
(103, '2024-05-13 22:50:14', 3, 2, NULL),
(104, '2024-05-13 22:50:15', 3, 2, NULL),
(105, '2024-05-13 22:50:15', 5, 6, NULL),
(106, '2024-05-13 22:50:15', 2, 4, NULL),
(107, '2024-05-13 22:50:16', 6, 8, NULL),
(108, '2024-05-13 22:50:16', 5, 6, NULL),
(109, '2024-05-13 22:50:17', 5, 7, NULL),
(110, '2024-05-13 22:50:17', 1, 2, NULL),
(111, '2024-05-13 22:50:19', 7, 5, NULL),
(112, '2024-05-13 22:50:19', 8, 10, NULL),
(113, '2024-05-13 22:50:20', 6, 8, NULL),
(114, '2024-05-13 22:50:20', 5, 6, NULL),
(115, '2024-05-13 22:50:20', 2, 5, NULL),
(116, '2024-05-13 22:50:20', 3, 2, NULL),
(117, '2024-05-13 22:50:21', 5, 6, NULL),
(118, '2024-05-13 22:50:21', 2, 4, NULL),
(119, '2024-05-13 22:50:21', 2, 5, NULL),
(120, '2024-05-13 22:50:22', 8, 10, NULL),
(121, '2024-05-13 22:50:22', 5, 7, NULL),
(122, '2024-05-13 22:50:22', 6, 8, NULL),
(123, '2024-05-13 22:50:22', 5, 6, NULL),
(124, '2024-05-13 22:50:23', 6, 8, NULL),
(125, '2024-05-13 22:50:23', 4, 5, NULL),
(126, '2024-05-13 22:50:23', 3, 2, NULL),
(127, '2024-05-13 22:50:24', 5, 6, NULL),
(128, '2024-05-13 22:50:24', 5, 7, NULL),
(129, '2024-05-13 22:50:26', 8, 10, NULL),
(130, '2024-05-13 22:50:26', 7, 5, NULL),
(131, '2024-05-13 22:50:26', 5, 7, NULL),
(132, '2024-05-13 22:50:26', 1, 2, NULL),
(133, '2024-05-13 22:50:27', 6, 8, NULL),
(134, '2024-05-13 22:50:27', 2, 5, NULL),
(135, '2024-05-13 22:50:28', 6, 8, NULL),
(136, '2024-05-13 22:50:28', 2, 5, NULL),
(137, '2024-05-13 22:50:29', 8, 10, NULL),
(138, '2024-05-13 22:50:29', 6, 8, NULL),
(139, '2024-05-13 22:50:29', 4, 5, NULL),
(140, '2024-05-13 22:50:29', 1, 2, NULL),
(141, '2024-05-13 22:50:30', 5, 6, NULL),
(142, '2024-05-13 22:50:30', 5, 7, NULL),
(143, '2024-05-13 22:50:30', 2, 5, NULL),
(144, '2024-05-13 22:50:31', 8, 10, NULL),
(145, '2024-05-13 22:50:31', 6, 8, NULL),
(146, '2024-05-13 22:50:32', 7, 5, NULL),
(147, '2024-05-13 22:50:32', 1, 2, NULL),
(148, '2024-05-13 22:50:33', 2, 5, NULL),
(149, '2024-05-13 22:50:33', 2, 4, NULL),
(150, '2024-05-13 22:50:35', 1, 2, NULL),
(151, '2024-05-13 22:50:36', 5, 6, NULL),
(152, '2024-05-13 22:50:37', 6, 8, NULL),
(153, '2024-05-13 22:50:37', 7, 5, NULL),
(154, '2024-05-13 22:50:38', 8, 10, NULL),
(155, '2024-05-13 22:50:38', 3, 2, NULL),
(156, '2024-05-13 22:50:39', 5, 6, NULL),
(157, '2024-05-13 22:50:39', 7, 5, NULL),
(158, '2024-05-13 22:50:41', 3, 2, NULL),
(159, '2024-05-13 22:50:41', 7, 5, NULL),
(160, '2024-05-13 22:50:41', 4, 5, NULL),
(161, '2024-05-13 22:50:41', 1, 2, NULL),
(162, '2024-05-13 22:50:42', 5, 6, NULL),
(163, '2024-05-13 22:50:42', 5, 7, NULL),
(164, '2024-05-13 22:50:42', 2, 5, NULL),
(165, '2024-05-13 22:50:43', 8, 10, NULL),
(166, '2024-05-13 22:50:43', 6, 8, NULL),
(167, '2024-05-13 22:50:43', 3, 2, NULL),
(168, '2024-05-13 22:50:43', 5, 6, NULL),
(169, '2024-05-13 22:50:44', 8, 10, NULL),
(170, '2024-05-13 22:50:44', 5, 7, NULL),
(171, '2024-05-13 22:50:44', 3, 2, NULL),
(172, '2024-05-13 22:50:45', 7, 5, NULL),
(173, '2024-05-13 22:50:45', 5, 7, NULL),
(174, '2024-05-13 22:50:46', 6, 8, NULL),
(175, '2024-05-13 22:50:47', 1, 2, NULL),
(176, '2024-05-13 22:50:49', 6, 8, NULL),
(177, '2024-05-13 22:50:50', 3, 2, NULL),
(178, '2024-05-13 22:50:50', 6, 8, NULL),
(179, '2024-05-13 22:50:50', 1, 2, NULL),
(180, '2024-05-13 22:50:51', 2, 5, NULL),
(181, '2024-05-13 22:50:52', 8, 10, NULL),
(182, '2024-05-13 22:50:53', 2, 4, NULL),
(183, '2024-05-13 22:50:53', 1, 2, NULL),
(184, '2024-05-13 22:50:54', 2, 5, NULL),
(185, '2024-05-13 22:50:54', 3, 2, NULL),
(186, '2024-05-13 22:50:56', 1, 2, NULL),
(187, '2024-05-13 22:50:57', 5, 7, NULL),
(188, '2024-05-13 22:50:57', 7, 5, NULL),
(189, '2024-05-13 22:50:57', 2, 5, NULL),
(190, '2024-05-13 22:50:58', 3, 2, NULL),
(191, '2024-05-13 22:50:59', 7, 5, NULL),
(192, '2024-05-13 22:50:59', 3, 2, NULL),
(193, '2024-05-13 22:51:00', 2, 4, NULL),
(194, '2024-05-13 22:51:00', 7, 5, NULL),
(195, '2024-05-13 22:51:00', 2, 5, NULL),
(196, '2024-05-13 22:51:00', 2, 4, NULL),
(197, '2024-05-13 22:51:01', 4, 5, NULL),
(198, '2024-05-13 22:51:01', 5, 6, NULL),
(199, '2024-05-13 22:51:02', 1, 2, NULL),
(200, '2024-05-13 22:51:04', 8, 10, NULL),
(201, '2024-05-13 22:51:04', 2, 4, NULL),
(202, '2024-05-13 22:51:04', 5, 7, NULL),
(203, '2024-05-13 22:51:05', 8, 10, NULL),
(204, '2024-05-13 22:51:05', 1, 2, NULL),
(205, '2024-05-13 22:51:06', 2, 4, NULL),
(206, '2024-05-13 22:51:07', 5, 6, NULL),
(207, '2024-05-13 22:51:08', 4, 5, NULL),
(208, '2024-05-13 22:51:08', 6, 8, NULL),
(209, '2024-05-13 22:51:08', 4, 5, NULL),
(210, '2024-05-13 22:51:08', 1, 2, NULL),
(211, '2024-05-13 22:51:10', 3, 2, NULL),
(212, '2024-05-13 22:51:11', 2, 5, NULL),
(213, '2024-05-13 22:51:11', 5, 7, NULL),
(214, '2024-05-13 22:51:11', 1, 2, NULL),
(215, '2024-05-13 22:51:12', 7, 5, NULL),
(216, '2024-05-13 22:51:12', 4, 5, NULL),
(217, '2024-05-13 22:51:12', 3, 2, NULL),
(218, '2024-05-13 22:51:12', 2, 4, NULL),
(219, '2024-05-13 22:51:12', 2, 5, NULL),
(220, '2024-05-13 22:51:13', 3, 2, NULL),
(221, '2024-05-13 22:51:13', 3, 2, NULL),
(222, '2024-05-13 22:51:14', 6, 8, NULL),
(223, '2024-05-13 22:51:14', 4, 5, NULL),
(224, '2024-05-13 22:51:14', 3, 2, NULL),
(225, '2024-05-13 22:51:17', 3, 2, NULL),
(226, '2024-05-13 22:51:18', 2, 5, NULL),
(227, '2024-05-13 22:51:19', 7, 5, NULL),
(228, '2024-05-13 22:51:20', 2, 4, NULL),
(229, '2024-05-13 22:51:20', 4, 5, NULL),
(230, '2024-05-13 22:51:20', 3, 2, NULL),
(231, '2024-05-13 22:51:21', 5, 6, NULL),
(232, '2024-05-13 22:51:21', 2, 4, NULL),
(233, '2024-05-13 22:51:23', 8, 10, NULL),
(234, '2024-05-13 22:51:23', 2, 4, NULL),
(235, '2024-05-13 22:51:23', 5, 7, NULL),
(236, '2024-05-13 22:51:23', 3, 2, NULL),
(237, '2024-05-13 22:51:24', 2, 4, NULL),
(238, '2024-05-13 22:51:25', 3, 2, NULL),
(239, '2024-05-13 22:51:25', 3, 2, NULL),
(240, '2024-05-13 22:51:25', 2, 5, NULL),
(241, '2024-05-13 22:51:25', 3, 2, NULL),
(242, '2024-05-13 22:51:26', 2, 5, NULL),
(243, '2024-05-13 22:51:26', 7, 5, NULL),
(244, '2024-05-13 22:51:26', 1, 2, NULL),
(245, '2024-05-13 22:51:27', 3, 2, NULL),
(246, '2024-05-13 22:51:27', 2, 4, NULL),
(247, '2024-05-13 22:51:28', 6, 8, NULL),
(248, '2024-05-13 22:51:28', 4, 5, NULL),
(249, '2024-05-13 22:51:29', 8, 10, NULL),
(250, '2024-05-13 22:51:29', 5, 7, NULL),
(251, '2024-05-13 22:51:29', 4, 5, NULL),
(252, '2024-05-13 22:51:29', 3, 2, NULL),
(253, '2024-05-13 22:51:30', 2, 4, NULL),
(254, '2024-05-13 22:51:31', 5, 7, NULL),
(255, '2024-05-13 22:51:31', 4, 5, NULL),
(256, '2024-05-13 22:51:31', 3, 2, NULL),
(257, '2024-05-13 22:51:32', 3, 2, NULL),
(258, '2024-05-13 22:51:32', 4, 5, NULL),
(259, '2024-05-13 22:51:32', 1, 2, NULL),
(260, '2024-05-13 22:51:34', 5, 7, NULL),
(261, '2024-05-13 22:51:35', 2, 4, NULL),
(262, '2024-05-13 22:51:35', 2, 4, NULL),
(263, '2024-05-13 22:51:35', 4, 5, NULL),
(264, '2024-05-13 22:51:35', 5, 7, NULL),
(265, '2024-05-13 22:51:35', 1, 2, NULL),
(266, '2024-05-13 22:51:35', 2, 4, NULL),
(267, '2024-05-13 22:51:36', 2, 5, NULL),
(268, '2024-05-13 22:51:36', 2, 4, NULL),
(269, '2024-05-13 22:51:38', 3, 2, NULL),
(270, '2024-05-13 22:51:38', 7, 5, NULL),
(271, '2024-05-13 22:51:38', 1, 2, NULL),
(272, '2024-05-13 22:51:38', 4, 5, NULL),
(273, '2024-05-13 22:51:39', 3, 2, NULL),
(274, '2024-05-13 22:51:39', 2, 4, NULL),
(275, '2024-05-13 22:51:40', 2, 5, NULL),
(276, '2024-05-13 22:51:41', 2, 4, NULL),
(277, '2024-05-13 22:51:41', 5, 7, NULL),
(278, '2024-05-13 22:51:41', 3, 2, NULL),
(279, '2024-05-13 22:51:42', 2, 4, NULL),
(280, '2024-05-13 22:51:42', 3, 2, NULL),
(281, '2024-05-13 22:51:43', 4, 5, NULL),
(282, '2024-05-13 22:51:43', 8, 10, NULL),
(283, '2024-05-13 22:51:43', 4, 5, NULL),
(284, '2024-05-13 22:51:43', 4, 5, NULL),
(285, '2024-05-13 22:51:44', 7, 5, NULL),
(286, '2024-05-13 22:51:44', 4, 5, NULL),
(287, '2024-05-13 22:51:44', 1, 2, NULL),
(288, '2024-05-13 22:51:45', 5, 6, NULL),
(289, '2024-05-13 22:51:46', 7, 5, NULL),
(290, '2024-05-13 22:51:46', 5, 6, NULL),
(291, '2024-05-13 22:51:46', 5, 7, NULL),
(292, '2024-05-13 22:51:47', 5, 7, NULL),
(293, '2024-05-13 22:51:47', 4, 5, NULL),
(294, '2024-05-13 22:51:47', 3, 2, NULL),
(295, '2024-05-13 22:51:48', 2, 4, NULL),
(296, '2024-05-13 22:51:48', 5, 6, NULL),
(297, '2024-05-13 22:51:49', 5, 7, NULL),
(298, '2024-05-13 22:51:49', 4, 5, NULL),
(299, '2024-05-13 22:51:49', 7, 5, NULL),
(300, '2024-05-13 22:51:50', 4, 5, NULL),
(301, '2024-05-13 22:51:50', 5, 6, NULL),
(302, '2024-05-13 22:51:50', 7, 5, NULL),
(303, '2024-05-13 22:51:50', 1, 2, NULL),
(304, '2024-05-13 22:51:51', 2, 5, NULL),
(305, '2024-05-13 22:51:52', 2, 5, NULL),
(306, '2024-05-13 22:51:52', 5, 7, NULL),
(307, '2024-05-13 22:51:52', 6, 8, NULL),
(308, '2024-05-13 22:51:53', 5, 7, NULL),
(309, '2024-05-13 22:51:53', 6, 8, NULL),
(310, '2024-05-13 22:51:53', 5, 7, NULL),
(311, '2024-05-13 22:51:53', 3, 2, NULL),
(312, '2024-05-13 22:51:54', 5, 6, NULL),
(313, '2024-05-13 22:51:54', 2, 5, NULL),
(314, '2024-05-13 22:51:55', 6, 8, NULL),
(315, '2024-05-13 22:51:55', 2, 5, NULL),
(316, '2024-05-13 22:51:56', 3, 2, NULL),
(317, '2024-05-13 22:51:56', 4, 5, NULL),
(318, '2024-05-13 22:51:56', 7, 5, NULL),
(319, '2024-05-13 22:51:56', 1, 2, NULL),
(320, '2024-05-13 22:51:57', 6, 8, NULL),
(321, '2024-05-13 22:51:57', 5, 6, NULL),
(322, '2024-05-13 22:51:59', 5, 7, NULL),
(323, '2024-05-13 22:51:59', 5, 6, NULL),
(324, '2024-05-13 22:51:59', 3, 2, NULL),
(325, '2024-05-13 22:52:00', 2, 5, NULL),
(326, '2024-05-13 22:52:00', 2, 4, NULL),
(327, '2024-05-13 22:52:01', 6, 8, NULL),
(328, '2024-05-13 22:52:01', 7, 5, NULL),
(329, '2024-05-13 22:52:02', 5, 6, NULL),
(330, '2024-05-13 22:52:02', 7, 5, NULL),
(331, '2024-05-13 22:52:02', 1, 2, NULL),
(332, '2024-05-13 22:52:03', 5, 7, NULL),
(333, '2024-05-13 22:52:04', 7, 5, NULL),
(334, '2024-05-13 22:52:04', 6, 8, NULL),
(335, '2024-05-13 22:52:04', 3, 2, NULL),
(336, '2024-05-13 22:52:05', 5, 6, NULL),
(337, '2024-05-13 22:52:05', 1, 2, NULL),
(338, '2024-05-13 22:52:06', 6, 8, NULL),
(339, '2024-05-13 22:52:06', 2, 5, NULL),
(340, '2024-05-13 22:52:07', 5, 7, NULL),
(341, '2024-05-13 22:52:07', 7, 5, NULL),
(342, '2024-05-13 22:52:07', 8, 10, NULL),
(343, '2024-05-13 22:52:07', 3, 2, NULL),
(344, '2024-05-13 22:52:08', 7, 5, NULL),
(345, '2024-05-13 22:52:08', 8, 10, NULL),
(346, '2024-05-13 22:52:08', 7, 5, NULL),
(347, '2024-05-13 22:52:08', 4, 5, NULL),
(348, '2024-05-13 22:52:08', 3, 2, NULL),
(349, '2024-05-13 22:52:09', 2, 5, NULL),
(350, '2024-05-13 22:52:09', 6, 8, NULL),
(351, '2024-05-13 22:52:09', 3, 2, NULL),
(352, '2024-05-13 22:52:10', 8, 10, NULL),
(353, '2024-05-13 22:52:11', 5, 7, NULL),
(354, '2024-05-13 22:52:11', 5, 7, NULL),
(355, '2024-05-13 22:52:11', 1, 2, NULL),
(356, '2024-05-13 22:52:12', 6, 8, NULL),
(357, '2024-05-13 22:52:12', 2, 5, NULL),
(358, '2024-05-13 22:52:14', 7, 5, NULL),
(359, '2024-05-13 22:52:14', 3, 2, NULL),
(360, '2024-05-13 22:52:14', 1, 2, NULL),
(361, '2024-05-13 22:52:15', 3, 2, NULL),
(362, '2024-05-13 22:52:15', 2, 5, NULL),
(363, '2024-05-13 22:52:16', 8, 10, NULL),
(364, '2024-05-13 22:52:17', 2, 5, NULL),
(365, '2024-05-13 22:52:17', 1, 2, NULL),
(366, '2024-05-13 22:52:18', 5, 6, NULL),
(367, '2024-05-13 22:52:18', 7, 5, NULL),
(368, '2024-05-13 22:52:18', 2, 4, NULL),
(369, '2024-05-13 22:52:19', 8, 10, NULL),
(370, '2024-05-13 22:52:19', 3, 2, NULL),
(371, '2024-05-13 22:52:20', 3, 2, NULL),
(372, '2024-05-13 22:52:20', 2, 5, NULL),
(373, '2024-05-13 22:52:20', 1, 2, NULL),
(374, '2024-05-13 22:52:22', 7, 5, NULL),
(375, '2024-05-13 22:52:22', 2, 5, NULL),
(376, '2024-05-13 22:52:22', 5, 6, NULL),
(377, '2024-05-13 22:52:23', 5, 7, NULL),
(378, '2024-05-13 22:52:23', 3, 2, NULL),
(379, '2024-05-13 22:52:24', 8, 10, NULL),
(380, '2024-05-13 22:52:24', 2, 4, NULL),
(381, '2024-05-13 22:52:24', 2, 5, NULL),
(382, '2024-05-13 22:52:25', 5, 7, NULL),
(383, '2024-05-13 22:52:26', 7, 5, NULL),
(384, '2024-05-13 22:52:26', 7, 5, NULL),
(385, '2024-05-13 22:52:26', 4, 5, NULL),
(386, '2024-05-13 22:52:26', 3, 2, NULL),
(387, '2024-05-13 22:52:27', 8, 10, NULL),
(388, '2024-05-13 22:52:27', 5, 7, NULL),
(389, '2024-05-13 22:52:27', 2, 4, NULL),
(390, '2024-05-13 22:52:28', 2, 5, NULL),
(391, '2024-05-13 22:52:28', 3, 2, NULL),
(392, '2024-05-13 22:52:29', 2, 4, NULL),
(393, '2024-05-13 22:52:29', 6, 8, NULL),
(394, '2024-05-13 22:52:29', 5, 7, NULL),
(395, '2024-05-13 22:52:29', 3, 2, NULL),
(396, '2024-05-13 22:52:30', 2, 4, NULL),
(397, '2024-05-13 22:52:30', 3, 2, NULL),
(398, '2024-05-13 22:52:30', 2, 4, NULL),
(399, '2024-05-13 22:52:31', 3, 2, NULL),
(400, '2024-05-13 22:52:32', 4, 5, NULL),
(401, '2024-05-13 22:52:32', 1, 2, NULL),
(402, '2024-05-13 22:52:33', 2, 4, NULL),
(403, '2024-05-13 22:52:35', 5, 7, NULL),
(404, '2024-05-13 22:52:35', 3, 2, NULL),
(405, '2024-05-13 22:52:35', 4, 5, NULL),
(406, '2024-05-13 22:52:35', 3, 2, NULL),
(407, '2024-05-13 22:52:37', 4, 5, NULL),
(408, '2024-05-13 22:52:38', 5, 6, NULL),
(409, '2024-05-13 22:52:38', 4, 5, NULL),
(410, '2024-05-13 22:52:38', 7, 5, NULL),
(411, '2024-05-13 22:52:38', 5, 7, NULL),
(412, '2024-05-13 22:52:38', 4, 5, NULL),
(413, '2024-05-13 22:52:38', 1, 2, NULL),
(414, '2024-05-13 22:52:39', 3, 2, NULL),
(415, '2024-05-13 22:52:39', 3, 2, NULL),
(416, '2024-05-13 22:52:39', 2, 5, NULL),
(417, '2024-05-13 22:52:39', 2, 4, NULL),
(418, '2024-05-13 22:52:40', 7, 5, NULL),
(419, '2024-05-13 22:52:41', 5, 7, NULL),
(420, '2024-05-13 22:52:41', 2, 5, NULL),
(421, '2024-05-13 22:52:41', 5, 7, NULL),
(422, '2024-05-13 22:52:41', 4, 5, NULL),
(423, '2024-05-13 22:52:41', 1, 2, NULL),
(424, '2024-05-13 22:52:42', 7, 5, NULL),
(425, '2024-05-13 22:52:43', 2, 5, NULL),
(426, '2024-05-13 22:52:44', 2, 5, NULL),
(427, '2024-05-13 22:52:44', 7, 5, NULL),
(428, '2024-05-13 22:52:44', 3, 2, NULL),
(429, '2024-05-13 22:52:45', 6, 8, NULL),
(430, '2024-05-13 22:52:47', 5, 6, NULL),
(431, '2024-05-13 22:52:47', 4, 5, NULL),
(432, '2024-05-13 22:52:47', 3, 2, NULL),
(433, '2024-05-13 22:52:48', 2, 5, NULL),
(434, '2024-05-13 22:52:48', 5, 6, NULL),
(435, '2024-05-13 22:52:48', 2, 5, NULL),
(436, '2024-05-13 22:52:49', 5, 6, NULL),
(437, '2024-05-13 22:52:49', 2, 4, NULL),
(438, '2024-05-13 22:52:50', 7, 5, NULL),
(439, '2024-05-13 22:52:50', 5, 7, NULL),
(440, '2024-05-13 22:52:51', 5, 6, NULL),
(441, '2024-05-13 22:52:51', 5, 6, NULL),
(442, '2024-05-13 22:52:51', 5, 7, NULL),
(443, '2024-05-13 22:52:52', 2, 5, NULL),
(444, '2024-05-13 22:52:53', 5, 6, NULL),
(445, '2024-05-13 22:52:53', 7, 5, NULL),
(446, '2024-05-13 22:52:53', 5, 7, NULL),
(447, '2024-05-13 22:52:54', 5, 6, NULL),
(448, '2024-05-13 22:52:54', 2, 5, NULL),
(449, '2024-05-13 22:52:54', 2, 4, NULL),
(450, '2024-05-13 22:52:54', 6, 8, NULL),
(451, '2024-05-13 22:52:55', 5, 7, NULL),
(452, '2024-05-13 22:52:55', 3, 2, NULL),
(453, '2024-05-13 22:52:55', 6, 8, NULL),
(454, '2024-05-13 22:52:56', 7, 5, NULL),
(455, '2024-05-13 22:52:56', 7, 5, NULL),
(456, '2024-05-13 22:52:56', 5, 7, NULL),
(457, '2024-05-13 22:52:57', 6, 8, NULL),
(458, '2024-05-13 22:52:57', 4, 5, NULL),
(459, '2024-05-13 22:52:57', 3, 2, NULL),
(460, '2024-05-13 22:52:58', 6, 8, NULL),
(461, '2024-05-13 22:52:58', 6, 8, NULL),
(462, '2024-05-13 22:52:59', 5, 7, NULL),
(463, '2024-05-13 22:53:00', 2, 5, NULL),
(464, '2024-05-13 22:53:00', 6, 8, NULL),
(465, '2024-05-13 22:53:01', 6, 8, NULL),
(466, '2024-05-13 22:53:02', 3, 2, NULL),
(467, '2024-05-13 22:53:02', 4, 5, NULL),
(468, '2024-05-13 22:53:05', 7, 5, NULL),
(469, '2024-05-13 22:53:06', 7, 5, NULL),
(470, '2024-05-13 22:53:07', 5, 6, NULL),
(471, '2024-05-13 22:53:07', 2, 4, NULL),
(472, '2024-05-13 22:53:07', 3, 2, NULL),
(473, '2024-05-13 22:53:08', 7, 5, NULL),
(474, '2024-05-13 22:53:08', 2, 5, NULL),
(475, '2024-05-13 22:53:09', 5, 7, NULL),
(476, '2024-05-13 22:53:09', 3, 2, NULL),
(477, '2024-05-13 22:53:10', 8, 10, NULL),
(478, '2024-05-13 22:53:10', 7, 5, NULL),
(479, '2024-05-13 22:53:11', 8, 10, NULL),
(480, '2024-05-13 22:53:12', 7, 5, NULL),
(481, '2024-05-13 22:53:12', 2, 4, NULL),
(482, '2024-05-13 22:53:12', 5, 6, NULL),
(483, '2024-05-13 22:53:13', 8, 10, NULL),
(484, '2024-05-13 22:53:13', 3, 2, NULL),
(485, '2024-05-13 22:53:14', 8, 10, NULL),
(486, '2024-05-13 22:53:15', 7, 5, NULL),
(487, '2024-05-13 22:53:15', 6, 8, NULL),
(488, '2024-05-13 22:53:15', 4, 5, NULL),
(489, '2024-05-13 22:53:15', 8, 10, NULL),
(490, '2024-05-13 22:53:16', 8, 10, NULL),
(491, '2024-05-13 22:53:18', 3, 2, NULL),
(492, '2024-05-13 22:53:19', 5, 7, NULL),
(493, '2024-05-13 22:53:19', 6, 8, NULL),
(494, '2024-05-13 22:53:20', 4, 5, NULL),
(495, '2024-05-13 22:53:21', 2, 5, NULL),
(496, '2024-05-13 22:53:22', 5, 6, NULL),
(497, '2024-05-13 22:53:22', 3, 2, NULL),
(498, '2024-05-13 22:53:23', 2, 5, NULL),
(499, '2024-05-13 22:53:24', 5, 7, NULL),
(500, '2024-05-13 22:53:24', 7, 5, NULL),
(501, '2024-05-13 22:53:26', 2, 5, NULL),
(502, '2024-05-13 22:53:28', 2, 4, NULL),
(503, '2024-05-13 22:53:29', 6, 8, NULL),
(504, '2024-05-13 22:53:29', 5, 7, NULL),
(505, '2024-05-13 22:53:30', 8, 10, NULL),
(506, '2024-05-13 22:53:33', 2, 4, NULL),
(507, '2024-05-13 22:53:34', 7, 5, NULL),
(508, '2024-05-13 22:53:34', 5, 6, NULL),
(509, '2024-05-13 22:53:36', 3, 2, NULL),
(510, '2024-05-13 22:53:36', 4, 5, NULL),
(511, '2024-05-13 22:53:37', 5, 7, NULL),
(512, '2024-05-13 22:53:39', 7, 5, NULL),
(513, '2024-05-13 22:53:41', 4, 5, NULL),
(514, '2024-05-13 22:53:41', 6, 8, NULL),
(515, '2024-05-13 22:53:42', 5, 7, NULL),
(516, '2024-05-13 22:53:44', 5, 7, NULL),
(517, '2024-05-13 22:53:45', 7, 5, NULL),
(518, '2024-05-13 22:53:47', 5, 6, NULL),
(519, '2024-05-13 22:53:49', 2, 5, NULL),
(520, '2024-05-13 22:53:52', 7, 5, NULL),
(521, '2024-05-13 22:53:54', 6, 8, NULL),
(522, '2024-05-13 22:53:55', 5, 6, NULL),
(523, '2024-05-13 22:53:58', 7, 5, NULL),
(524, '2024-05-13 22:53:59', 7, 5, NULL),
(525, '2024-05-13 22:53:59', 5, 6, NULL),
(526, '2024-05-13 22:54:01', 5, 7, NULL),
(527, '2024-05-13 22:54:02', 6, 8, NULL),
(528, '2024-05-13 22:54:07', 6, 8, NULL),
(529, '2024-05-13 22:54:09', 8, 10, NULL),
(530, '2024-05-13 22:54:16', 7, 5, NULL),
(531, '2024-05-13 22:54:17', 8, 10, NULL),
(532, '2024-05-13 22:54:19', 5, 7, NULL),
(533, '2024-05-13 22:54:34', 7, 5, NULL),
(534, '2024-05-13 22:55:00', 1, 2, 41),
(535, '2024-05-13 22:55:03', 3, 2, NULL),
(536, '2024-05-13 22:55:06', 3, 2, NULL),
(537, '2024-05-13 22:55:09', 1, 2, NULL),
(538, '2024-05-13 22:55:10', 2, 4, NULL),
(539, '2024-05-13 22:55:12', 3, 2, NULL),
(540, '2024-05-13 22:55:13', 2, 4, NULL),
(541, '2024-05-13 22:55:15', 1, 2, NULL),
(542, '2024-05-13 22:55:16', 2, 4, NULL),
(543, '2024-05-13 22:55:18', 4, 5, NULL),
(544, '2024-05-13 22:55:18', 1, 2, NULL),
(545, '2024-05-13 22:55:21', 5, 7, NULL),
(546, '2024-05-13 22:55:21', 4, 5, NULL),
(547, '2024-05-13 22:55:21', 3, 2, NULL),
(548, '2024-05-13 22:55:22', 2, 5, NULL),
(549, '2024-05-13 22:55:22', 2, 4, NULL),
(550, '2024-05-13 22:55:24', 4, 5, NULL),
(551, '2024-05-13 22:55:24', 1, 2, NULL),
(552, '2024-05-13 22:55:25', 5, 7, NULL),
(553, '2024-05-13 22:55:25', 2, 4, NULL),
(554, '2024-05-13 22:55:27', 5, 7, NULL),
(555, '2024-05-13 22:55:27', 3, 2, NULL),
(556, '2024-05-13 22:55:30', 4, 5, NULL),
(557, '2024-05-13 22:55:30', 1, 2, NULL),
(558, '2024-05-13 22:55:31', 5, 6, NULL),
(559, '2024-05-13 22:55:31', 2, 5, NULL),
(560, '2024-05-13 22:55:31', 2, 4, NULL),
(561, '2024-05-13 22:55:33', 4, 5, NULL),
(562, '2024-05-13 22:55:33', 1, 2, NULL),
(563, '2024-05-13 22:55:36', 7, 5, NULL),
(564, '2024-05-13 22:55:36', 5, 7, NULL),
(565, '2024-05-13 22:55:36', 1, 2, NULL),
(566, '2024-05-13 22:55:38', 6, 8, NULL),
(567, '2024-05-13 22:55:39', 4, 5, NULL),
(568, '2024-05-13 22:55:39', 1, 2, NULL),
(569, '2024-05-13 22:55:40', 7, 5, NULL),
(570, '2024-05-13 22:55:40', 5, 6, NULL),
(571, '2024-05-13 22:55:40', 2, 5, NULL),
(572, '2024-05-13 22:55:41', 8, 9, NULL),
(573, '2024-05-13 22:55:41', 5, 6, NULL),
(574, '2024-05-13 22:55:42', 5, 7, NULL),
(575, '2024-05-13 22:55:42', 3, 2, NULL),
(576, '2024-05-13 22:55:43', 2, 4, NULL),
(577, '2024-05-13 22:55:43', 5, 7, NULL),
(578, '2024-05-13 22:55:45', 3, 2, NULL),
(579, '2024-05-13 22:55:47', 6, 8, NULL),
(580, '2024-05-13 22:55:48', 6, 8, NULL),
(581, '2024-05-13 22:55:48', 1, 2, NULL),
(582, '2024-05-13 22:55:49', 3, 2, NULL),
(583, '2024-05-13 22:55:49', 2, 5, NULL),
(584, '2024-05-13 22:55:49', 2, 4, NULL),
(585, '2024-05-13 22:55:50', 5, 6, NULL),
(586, '2024-05-13 22:55:51', 8, 9, NULL),
(587, '2024-05-13 22:55:51', 4, 5, NULL),
(588, '2024-05-13 22:55:51', 1, 2, NULL),
(589, '2024-05-13 22:55:53', 9, 7, NULL),
(590, '2024-05-13 22:55:54', 5, 7, NULL),
(591, '2024-05-13 22:55:54', 1, 2, NULL),
(592, '2024-05-13 22:55:55', 2, 5, NULL),
(593, '2024-05-13 22:55:57', 6, 8, NULL),
(594, '2024-05-13 22:55:57', 7, 5, NULL),
(595, '2024-05-13 22:55:57', 4, 5, NULL),
(596, '2024-05-13 22:55:57', 1, 2, NULL),
(597, '2024-05-13 22:55:58', 7, 5, NULL),
(598, '2024-05-13 22:55:58', 5, 7, NULL),
(599, '2024-05-13 22:55:58', 2, 5, NULL),
(600, '2024-05-13 22:56:00', 8, 9, NULL),
(601, '2024-05-13 22:56:00', 3, 2, NULL),
(602, '2024-05-13 22:56:01', 5, 7, NULL),
(603, '2024-05-13 22:57:19', 3, 2, NULL),
(604, '2024-05-13 22:57:20', 7, 5, NULL),
(605, '2024-05-13 22:57:20', 5, 7, NULL),
(606, '2024-05-13 22:57:21', 6, 8, NULL),
(607, '2024-05-13 22:57:21', 2, 4, NULL),
(608, '2024-05-13 22:57:21', 7, 5, NULL),
(609, '2024-05-13 22:57:21', 8, 9, NULL),
(610, '2024-05-13 22:57:21', 2, 5, NULL),
(611, '2024-05-13 22:57:21', 1, 2, NULL),
(612, '2024-05-13 22:57:22', 2, 5, NULL),
(613, '2024-05-13 22:57:22', 2, 4, NULL),
(614, '2024-05-13 22:57:23', 4, 5, NULL),
(615, '2024-05-13 22:57:24', 4, 5, NULL),
(616, '2024-05-13 22:57:24', 1, 2, NULL),
(617, '2024-05-13 22:57:24', 4, 5, NULL),
(618, '2024-05-13 22:57:25', 7, 5, NULL),
(619, '2024-05-13 22:57:25', 2, 5, NULL),
(620, '2024-05-13 22:57:25', 5, 7, NULL),
(621, '2024-05-13 22:57:25', 2, 4, NULL),
(622, '2024-05-13 22:57:27', 5, 7, NULL),
(623, '2024-05-13 22:57:27', 1, 2, NULL),
(624, '2024-05-13 22:57:27', 5, 7, NULL),
(625, '2024-05-13 22:57:28', 5, 6, NULL),
(626, '2024-05-13 22:57:29', 8, 10, NULL),
(627, '2024-05-13 22:57:29', 4, 5, NULL),
(628, '2024-05-13 22:57:29', 3, 2, NULL),
(629, '2024-05-13 22:57:30', 5, 6, NULL),
(630, '2024-05-13 22:57:30', 9, 7, NULL),
(631, '2024-05-13 22:57:30', 7, 5, NULL),
(632, '2024-05-13 22:57:30', 4, 5, NULL),
(633, '2024-05-13 22:57:30', 3, 2, NULL),
(634, '2024-05-13 22:57:31', 5, 6, NULL),
(635, '2024-05-13 22:57:31', 5, 6, NULL),
(636, '2024-05-13 22:57:31', 2, 4, NULL),
(637, '2024-05-13 22:57:32', 2, 5, NULL),
(638, '2024-05-13 22:57:33', 7, 5, NULL),
(639, '2024-05-13 22:57:33', 4, 5, NULL),
(640, '2024-05-13 22:57:33', 1, 2, NULL),
(641, '2024-05-13 22:57:34', 7, 5, NULL),
(642, '2024-05-13 22:57:34', 7, 5, NULL),
(643, '2024-05-13 22:57:35', 7, 5, NULL),
(644, '2024-05-13 22:57:35', 6, 8, NULL),
(645, '2024-05-13 22:57:36', 8, 10, NULL),
(646, '2024-05-13 22:57:36', 3, 2, NULL),
(647, '2024-05-13 22:57:36', 5, 7, NULL),
(648, '2024-05-13 22:57:36', 3, 2, NULL),
(649, '2024-05-13 22:57:37', 6, 8, NULL),
(650, '2024-05-13 22:57:37', 5, 7, NULL),
(651, '2024-05-13 22:57:37', 2, 4, NULL),
(652, '2024-05-13 22:57:37', 2, 5, NULL),
(653, '2024-05-13 22:57:38', 6, 8, NULL),
(654, '2024-05-13 22:57:38', 3, 2, NULL),
(655, '2024-05-13 22:57:38', 3, 2, NULL),
(656, '2024-05-13 22:57:38', 6, 8, NULL),
(657, '2024-05-13 22:57:39', 4, 5, NULL),
(658, '2024-05-13 22:57:39', 3, 2, NULL),
(659, '2024-05-13 22:57:39', 2, 4, NULL),
(660, '2024-05-13 22:57:40', 7, 5, NULL),
(661, '2024-05-13 22:57:40', 5, 7, NULL),
(662, '2024-05-13 22:57:41', 8, 9, NULL),
(663, '2024-05-13 22:57:41', 8, 9, NULL),
(664, '2024-05-13 22:57:42', 7, 5, NULL),
(665, '2024-05-13 22:57:42', 3, 2, NULL),
(666, '2024-05-13 22:57:42', 1, 2, NULL),
(667, '2024-05-13 22:57:42', 7, 5, NULL),
(668, '2024-05-13 22:57:43', 5, 6, NULL),
(669, '2024-05-13 22:57:43', 3, 2, NULL),
(670, '2024-05-13 22:57:43', 5, 7, NULL),
(671, '2024-05-13 22:57:43', 3, 2, NULL),
(672, '2024-05-13 22:57:43', 2, 5, NULL),
(673, '2024-05-13 22:57:45', 5, 6, NULL),
(674, '2024-05-13 22:57:45', 7, 5, NULL),
(675, '2024-05-13 22:57:45', 4, 5, NULL),
(676, '2024-05-13 22:57:45', 1, 2, NULL),
(677, '2024-05-13 22:57:45', 3, 2, NULL),
(678, '2024-05-13 22:57:46', 2, 5, NULL),
(679, '2024-05-13 22:57:46', 5, 7, NULL),
(680, '2024-05-13 22:57:47', 3, 2, NULL),
(681, '2024-05-13 22:57:47', 4, 5, NULL),
(682, '2024-05-13 22:57:48', 5, 7, NULL),
(683, '2024-05-13 22:57:48', 3, 2, NULL),
(684, '2024-05-13 22:57:49', 2, 5, NULL),
(685, '2024-05-13 22:57:49', 5, 7, NULL),
(686, '2024-05-13 22:57:49', 2, 5, NULL),
(687, '2024-05-13 22:57:49', 2, 4, NULL),
(688, '2024-05-13 22:57:50', 6, 8, NULL),
(689, '2024-05-13 22:57:50', 8, 10, NULL),
(690, '2024-05-13 22:57:51', 2, 5, NULL),
(691, '2024-05-13 22:57:51', 2, 5, NULL),
(692, '2024-05-13 22:57:51', 1, 2, NULL),
(693, '2024-05-13 22:57:52', 7, 5, NULL),
(694, '2024-05-13 22:57:52', 2, 4, NULL),
(695, '2024-05-13 22:57:52', 6, 8, NULL),
(696, '2024-05-13 22:57:52', 3, 2, NULL),
(697, '2024-05-13 22:57:52', 5, 7, NULL),
(698, '2024-05-13 22:57:53', 9, 7, NULL),
(699, '2024-05-13 22:57:53', 9, 7, NULL),
(700, '2024-05-13 22:57:54', 1, 2, NULL),
(701, '2024-05-13 22:57:55', 8, 9, NULL),
(702, '2024-05-13 22:57:55', 5, 6, NULL),
(703, '2024-05-13 22:57:55', 7, 5, NULL),
(704, '2024-05-13 22:57:55', 2, 4, NULL),
(705, '2024-05-13 22:57:55', 3, 2, NULL),
(706, '2024-05-13 22:57:56', 2, 5, NULL),
(707, '2024-05-13 22:57:56', 2, 5, NULL),
(708, '2024-05-13 22:57:57', 2, 4, NULL),
(709, '2024-05-13 22:57:57', 4, 5, NULL),
(710, '2024-05-13 22:57:57', 1, 2, NULL),
(711, '2024-05-13 22:57:57', 5, 6, NULL),
(712, '2024-05-13 22:57:58', 7, 5, NULL),
(713, '2024-05-13 22:57:58', 5, 7, NULL),
(714, '2024-05-13 22:57:58', 2, 5, NULL),
(715, '2024-05-13 22:57:59', 5, 7, NULL),
(716, '2024-05-13 22:58:00', 1, 2, NULL),
(717, '2024-05-13 22:58:01', 5, 6, NULL),
(718, '2024-05-13 22:58:01', 5, 7, NULL),
(719, '2024-05-13 22:58:01', 5, 7, NULL),
(720, '2024-05-13 22:58:01', 2, 5, NULL),
(721, '2024-05-13 22:58:01', 2, 4, NULL),
(722, '2024-05-13 22:58:02', 3, 2, NULL),
(723, '2024-05-13 22:58:02', 6, 8, NULL),
(724, '2024-05-13 22:58:02', 2, 4, NULL),
(725, '2024-05-13 22:58:03', 1, 2, NULL),
(726, '2024-05-13 22:58:03', 4, 5, NULL),
(727, '2024-05-13 22:58:04', 6, 8, NULL),
(728, '2024-05-13 22:58:05', 8, 10, NULL),
(729, '2024-05-13 22:58:05', 4, 5, NULL),
(730, '2024-05-13 22:58:06', 5, 6, NULL),
(731, '2024-05-13 22:58:06', 1, 2, NULL),
(732, '2024-05-13 22:58:06', 5, 7, NULL),
(733, '2024-05-13 22:58:07', 9, 7, NULL),
(734, '2024-05-13 22:58:07', 7, 5, NULL),
(735, '2024-05-13 22:58:07', 5, 6, NULL),
(736, '2024-05-13 22:58:07', 2, 5, NULL),
(737, '2024-05-13 22:58:07', 8, 9, NULL),
(738, '2024-05-13 22:58:08', 7, 5, NULL),
(739, '2024-05-13 22:58:08', 6, 8, NULL),
(740, '2024-05-13 22:58:08', 7, 5, NULL),
(741, '2024-05-13 22:58:08', 2, 5, NULL),
(742, '2024-05-13 22:58:09', 4, 5, NULL),
(743, '2024-05-13 22:58:09', 3, 2, NULL),
(744, '2024-05-13 22:58:10', 4, 5, NULL),
(745, '2024-05-13 22:58:10', 5, 7, NULL),
(746, '2024-05-13 22:58:10', 2, 4, NULL),
(747, '2024-05-13 22:58:11', 5, 6, NULL),
(748, '2024-05-13 22:58:12', 2, 4, NULL),
(749, '2024-05-13 22:58:12', 5, 7, NULL),
(750, '2024-05-13 22:58:12', 3, 2, NULL),
(751, '2024-05-13 22:58:13', 6, 8, NULL),
(752, '2024-05-13 22:58:13', 7, 5, NULL),
(753, '2024-05-13 22:58:13', 5, 7, NULL),
(754, '2024-05-13 22:58:14', 7, 5, NULL),
(755, '2024-05-13 22:58:14', 6, 8, NULL),
(756, '2024-05-13 22:58:15', 1, 2, NULL),
(757, '2024-05-13 22:58:16', 7, 5, NULL),
(758, '2024-05-13 22:58:16', 8, 9, NULL),
(759, '2024-05-13 22:58:17', 8, 10, NULL),
(760, '2024-05-13 22:58:17', 5, 7, NULL),
(761, '2024-05-13 22:58:17', 5, 6, NULL),
(762, '2024-05-13 22:58:17', 8, 9, NULL),
(763, '2024-05-13 22:58:18', 5, 6, NULL),
(764, '2024-05-13 22:58:18', 6, 8, NULL),
(765, '2024-05-13 22:58:18', 4, 5, NULL),
(766, '2024-05-13 22:58:18', 1, 2, NULL),
(767, '2024-05-13 22:58:19', 5, 7, NULL),
(768, '2024-05-13 22:58:19', 2, 5, NULL),
(769, '2024-05-13 22:58:20', 4, 5, NULL),
(770, '2024-05-13 22:58:21', 1, 2, NULL),
(771, '2024-05-13 22:58:21', 3, 2, NULL),
(772, '2024-05-13 22:58:21', 7, 5, NULL),
(773, '2024-05-13 22:58:22', 7, 5, NULL),
(774, '2024-05-13 22:58:22', 2, 5, NULL),
(775, '2024-05-13 22:58:23', 8, 10, NULL),
(776, '2024-05-13 22:58:23', 5, 6, NULL),
(777, '2024-05-13 22:58:24', 6, 8, NULL),
(778, '2024-05-13 22:58:24', 3, 2, NULL),
(779, '2024-05-13 22:58:25', 6, 8, NULL),
(780, '2024-05-13 22:58:25', 7, 5, NULL),
(781, '2024-05-13 22:58:25', 5, 7, NULL),
(782, '2024-05-13 22:58:25', 2, 5, NULL),
(783, '2024-05-13 22:58:27', 8, 9, NULL),
(784, '2024-05-13 22:58:27', 7, 5, NULL),
(785, '2024-05-13 22:58:27', 3, 2, NULL),
(786, '2024-05-13 22:58:28', 8, 9, NULL),
(787, '2024-05-13 22:58:28', 7, 5, NULL),
(788, '2024-05-13 22:58:28', 5, 7, NULL),
(789, '2024-05-13 22:58:28', 2, 5, NULL),
(790, '2024-05-13 22:58:28', 2, 4, NULL),
(791, '2024-05-13 22:58:30', 6, 8, NULL),
(792, '2024-05-13 22:58:30', 3, 2, NULL),
(793, '2024-05-13 22:58:31', 3, 2, NULL),
(794, '2024-05-13 22:58:31', 5, 7, NULL),
(795, '2024-05-13 22:58:31', 5, 6, NULL),
(796, '2024-05-13 22:58:32', 7, 5, NULL),
(797, '2024-05-13 22:58:32', 3, 2, NULL),
(798, '2024-05-13 22:58:33', 8, 9, NULL),
(799, '2024-05-13 22:58:33', 8, 10, NULL),
(800, '2024-05-13 22:58:33', 3, 2, NULL),
(801, '2024-05-13 22:58:34', 7, 5, NULL),
(802, '2024-05-13 22:58:34', 2, 5, NULL),
(803, '2024-05-13 22:58:34', 2, 5, NULL),
(804, '2024-05-13 22:58:36', 4, 5, NULL),
(805, '2024-05-13 22:58:36', 1, 2, NULL),
(806, '2024-05-13 22:58:37', 5, 7, NULL),
(807, '2024-05-13 22:58:37', 2, 5, NULL),
(808, '2024-05-13 22:58:37', 5, 7, NULL),
(809, '2024-05-13 22:58:38', 3, 2, NULL),
(810, '2024-05-13 22:58:39', 9, 7, NULL),
(811, '2024-05-13 22:58:39', 1, 2, NULL),
(812, '2024-05-13 22:58:40', 9, 7, NULL),
(813, '2024-05-13 22:58:40', 3, 2, NULL),
(814, '2024-05-13 22:58:40', 2, 5, NULL),
(815, '2024-05-13 22:58:41', 3, 2, NULL),
(816, '2024-05-13 22:58:41', 2, 4, NULL),
(817, '2024-05-13 22:58:42', 2, 4, NULL),
(818, '2024-05-13 22:58:42', 1, 2, NULL),
(819, '2024-05-13 22:58:43', 7, 5, NULL),
(820, '2024-05-13 22:58:43', 2, 5, NULL),
(821, '2024-05-13 22:58:43', 5, 7, NULL),
(822, '2024-05-13 22:58:43', 2, 4, NULL),
(823, '2024-05-13 22:58:44', 5, 6, NULL),
(824, '2024-05-13 22:58:45', 3, 2, NULL),
(825, '2024-05-13 22:58:45', 1, 2, NULL),
(826, '2024-05-13 22:58:46', 7, 5, NULL),
(827, '2024-05-13 22:58:47', 5, 6, NULL),
(828, '2024-05-13 22:58:48', 2, 4, NULL),
(829, '2024-05-13 22:58:48', 1, 2, NULL),
(830, '2024-05-13 22:58:49', 4, 5, NULL),
(831, '2024-05-13 22:58:49', 5, 7, NULL),
(832, '2024-05-13 22:58:49', 3, 2, NULL),
(833, '2024-05-13 22:58:49', 2, 5, NULL),
(834, '2024-05-13 22:58:50', 4, 5, NULL),
(835, '2024-05-13 22:58:51', 2, 4, NULL),
(836, '2024-05-13 22:58:51', 6, 8, NULL),
(837, '2024-05-13 22:58:51', 4, 5, NULL),
(838, '2024-05-13 22:58:51', 3, 2, NULL),
(839, '2024-05-13 22:58:52', 7, 5, NULL),
(840, '2024-05-13 22:58:52', 5, 7, NULL),
(841, '2024-05-13 22:58:52', 2, 4, NULL),
(842, '2024-05-13 22:58:52', 7, 5, NULL),
(843, '2024-05-13 22:58:53', 5, 6, NULL),
(844, '2024-05-13 22:58:53', 2, 5, NULL),
(845, '2024-05-13 22:58:53', 5, 6, NULL),
(846, '2024-05-13 22:58:54', 7, 5, NULL),
(847, '2024-05-13 22:58:54', 8, 9, NULL),
(848, '2024-05-13 22:58:54', 6, 8, NULL),
(849, '2024-05-13 22:58:54', 1, 2, NULL),
(850, '2024-05-13 22:58:54', 5, 7, NULL),
(851, '2024-05-13 22:58:55', 5, 7, NULL),
(852, '2024-05-13 22:58:56', 5, 7, NULL),
(853, '2024-05-13 22:58:56', 4, 5, NULL),
(854, '2024-05-13 22:58:57', 1, 2, NULL),
(855, '2024-05-13 22:58:58', 2, 5, NULL),
(856, '2024-05-13 22:58:58', 2, 5, NULL),
(857, '2024-05-13 22:58:59', 4, 5, NULL),
(858, '2024-05-13 22:58:59', 5, 6, NULL),
(859, '2024-05-13 22:58:59', 5, 7, NULL),
(860, '2024-05-13 22:59:00', 5, 6, NULL),
(861, '2024-05-13 22:59:00', 6, 8, NULL),
(862, '2024-05-13 22:59:00', 4, 5, NULL),
(863, '2024-05-13 22:59:00', 6, 8, NULL),
(864, '2024-05-13 22:59:02', 2, 5, NULL),
(865, '2024-05-13 22:59:02', 5, 6, NULL),
(866, '2024-05-13 22:59:02', 5, 7, NULL),
(867, '2024-05-13 22:59:03', 8, 9, NULL),
(868, '2024-05-13 22:59:03', 5, 7, NULL),
(869, '2024-05-13 22:59:04', 2, 4, NULL),
(870, '2024-05-13 22:59:04', 7, 5, NULL),
(871, '2024-05-13 22:59:04', 2, 5, NULL),
(872, '2024-05-13 22:59:06', 6, 8, NULL),
(873, '2024-05-13 22:59:07', 7, 5, NULL),
(874, '2024-05-13 22:59:07', 5, 7, NULL),
(875, '2024-05-13 22:59:07', 6, 8, NULL),
(876, '2024-05-13 22:59:08', 5, 7, NULL),
(877, '2024-05-13 22:59:08', 3, 2, NULL),
(878, '2024-05-13 22:59:09', 8, 10, NULL),
(879, '2024-05-13 22:59:09', 6, 8, NULL),
(880, '2024-05-13 22:59:09', 7, 5, NULL),
(881, '2024-05-13 22:59:09', 8, 9, NULL),
(882, '2024-05-13 22:59:10', 7, 5, NULL),
(883, '2024-05-13 22:59:10', 5, 7, NULL),
(884, '2024-05-13 22:59:11', 7, 5, NULL),
(885, '2024-05-13 22:59:12', 5, 6, NULL),
(886, '2024-05-13 22:59:13', 3, 2, NULL),
(887, '2024-05-13 22:59:13', 4, 5, NULL),
(888, '2024-05-13 22:59:15', 7, 5, NULL),
(889, '2024-05-13 22:59:15', 9, 7, NULL),
(890, '2024-05-13 22:59:15', 8, 10, NULL),
(891, '2024-05-13 22:59:16', 5, 7, NULL),
(892, '2024-05-13 22:59:19', 6, 8, NULL),
(893, '2024-05-13 22:59:21', 5, 6, NULL),
(894, '2024-05-13 22:59:22', 2, 5, NULL),
(895, '2024-05-13 22:59:22', 9, 7, NULL),
(896, '2024-05-13 22:59:22', 3, 2, NULL),
(897, '2024-05-13 22:59:23', 8, 10, NULL),
(898, '2024-05-13 22:59:23', 7, 5, NULL),
(899, '2024-05-13 22:59:25', 5, 6, NULL),
(900, '2024-05-13 22:59:26', 2, 5, NULL),
(901, '2024-05-13 22:59:26', 7, 5, NULL),
(902, '2024-05-13 22:59:29', 6, 8, NULL),
(903, '2024-05-13 22:59:31', 7, 5, NULL),
(904, '2024-05-13 22:59:32', 8, 9, NULL),
(905, '2024-05-13 22:59:32', 6, 8, NULL),
(906, '2024-05-13 22:59:33', 2, 4, NULL),
(907, '2024-05-13 22:59:34', 8, 10, NULL),
(908, '2024-05-13 22:59:35', 3, 2, NULL),
(909, '2024-05-13 22:59:36', 5, 6, NULL),
(910, '2024-05-13 22:59:36', 3, 2, NULL),
(911, '2024-05-13 22:59:37', 7, 5, NULL),
(912, '2024-05-13 22:59:41', 4, 5, NULL),
(913, '2024-05-13 22:59:41', 5, 6, NULL),
(914, '2024-05-13 22:59:44', 6, 8, NULL),
(915, '2024-05-13 22:59:44', 9, 7, NULL),
(916, '2024-05-13 22:59:47', 2, 4, NULL),
(917, '2024-05-13 22:59:47', 8, 9, NULL),
(918, '2024-05-13 22:59:47', 5, 6, NULL),
(919, '2024-05-13 22:59:47', 8, 10, NULL),
(920, '2024-05-13 22:59:48', 2, 5, NULL),
(921, '2024-05-13 22:59:51', 5, 6, NULL),
(922, '2024-05-13 22:59:52', 5, 7, NULL),
(923, '2024-05-13 22:59:55', 6, 8, NULL),
(924, '2024-05-13 22:59:55', 4, 5, NULL),
(925, '2024-05-13 22:59:58', 6, 8, NULL),
(926, '2024-05-13 22:59:59', 9, 7, NULL),
(927, '2024-05-13 22:59:59', 7, 5, NULL),
(928, '2024-05-13 23:00:01', 8, 9, NULL),
(929, '2024-05-13 23:00:08', 3, 2, NULL),
(930, '2024-05-13 23:00:10', 8, 10, NULL),
(931, '2024-05-13 23:00:13', 9, 7, NULL),
(932, '2024-05-13 23:00:14', 7, 5, NULL),
(933, '2024-05-13 23:00:18', 2, 4, NULL),
(934, '2024-05-13 23:00:27', 3, 2, NULL),
(935, '2024-05-13 23:00:28', 7, 5, NULL),
(936, '2024-05-13 23:00:37', 2, 4, NULL),
(937, '2024-05-13 23:00:57', 3, 2, 41),
(938, '2024-05-13 23:01:00', 3, 2, 41),
(939, '2024-05-13 23:01:07', 2, 4, 41),
(940, '2024-05-13 23:01:12', 1, 2, 41),
(941, '2024-05-13 23:01:13', 2, 5, 41),
(942, '2024-05-13 23:01:15', 4, 5, 41),
(943, '2024-05-13 23:01:15', 3, 2, 41),
(944, '2024-05-13 23:01:18', 5, 7, 41),
(945, '2024-05-13 23:01:18', 3, 2, 41),
(946, '2024-05-13 23:01:21', 1, 2, 41),
(947, '2024-05-13 23:01:23', 5, 6, 41),
(948, '2024-05-13 23:01:24', 1, 2, 41),
(949, '2024-05-13 23:01:25', 2, 5, 41),
(950, '2024-05-13 23:01:28', 2, 5, 41),
(951, '2024-05-13 23:01:31', 2, 4, 41),
(952, '2024-05-13 23:01:31', 5, 7, 41),
(953, '2024-05-13 23:01:31', 2, 5, 41),
(954, '2024-05-13 23:01:33', 7, 5, 41),
(955, '2024-05-13 23:01:33', 3, 2, 41),
(956, '2024-05-13 23:01:34', 2, 4, 41),
(957, '2024-05-13 23:01:35', 5, 6, 41),
(958, '2024-05-13 23:01:36', 5, 7, 41),
(959, '2024-05-13 23:01:36', 3, 2, 41),
(960, '2024-05-13 23:01:41', 5, 6, 41),
(961, '2024-05-13 23:01:42', 4, 5, 41),
(962, '2024-05-13 23:01:42', 1, 2, 41),
(963, '2024-05-13 23:01:45', 1, 2, 41),
(964, '2024-05-13 23:01:46', 2, 5, 41),
(965, '2024-05-13 23:01:48', 1, 2, 41),
(966, '2024-05-13 23:01:49', 2, 5, 41),
(967, '2024-05-13 23:01:51', 7, 5, 41),
(968, '2024-05-13 23:01:51', 3, 2, 41),
(969, '2024-05-13 23:01:52', 5, 6, 41),
(970, '2024-05-13 23:01:54', 5, 7, 41),
(971, '2024-05-13 23:01:54', 3, 2, 41),
(972, '2024-05-13 23:01:55', 2, 5, 41),
(973, '2024-05-13 23:01:55', 2, 4, 41),
(974, '2024-05-13 23:01:58', 5, 7, 41),
(975, '2024-05-13 23:01:59', 6, 8, 41),
(976, '2024-05-13 23:01:59', 3, 2, 41),
(977, '2024-05-13 23:02:00', 1, 2, 41),
(978, '2024-05-13 23:02:01', 2, 5, 41),
(979, '2024-05-13 23:02:02', 3, 2, 41),
(980, '2024-05-13 23:02:03', 4, 5, 41),
(981, '2024-05-13 23:02:03', 3, 2, 41),
(982, '2024-05-13 23:02:04', 2, 5, 41),
(983, '2024-05-13 23:02:06', 5, 7, 41),
(984, '2024-05-13 23:02:06', 1, 2, 41),
(985, '2024-05-13 23:02:07', 2, 5, 41),
(986, '2024-05-13 23:02:09', 7, 5, 41),
(987, '2024-05-13 23:02:09', 2, 4, 41),
(988, '2024-05-13 23:02:09', 1, 2, 41),
(989, '2024-05-13 23:02:10', 2, 4, 41),
(990, '2024-05-13 23:02:11', 5, 6, 41),
(991, '2024-05-13 23:02:12', 5, 7, 41),
(992, '2024-05-13 23:02:12', 3, 2, 41),
(993, '2024-05-13 23:02:13', 7, 5, 41),
(994, '2024-05-13 23:02:13', 2, 4, 41),
(995, '2024-05-13 23:02:14', 8, 10, 41),
(996, '2024-05-13 23:02:14', 5, 6, 41),
(997, '2024-05-13 23:02:15', 2, 5, 41),
(998, '2024-05-13 23:02:16', 5, 7, 41),
(999, '2024-05-13 23:02:17', 4, 5, 41),
(1000, '2024-05-13 23:02:17', 5, 6, 41),
(1001, '2024-05-13 23:02:18', 5, 7, 41),
(1002, '2024-05-13 23:02:18', 4, 5, 41),
(1003, '2024-05-13 23:02:19', 2, 5, 41),
(1004, '2024-05-13 23:02:21', 6, 8, 41),
(1005, '2024-05-13 23:02:21', 5, 7, 41),
(1006, '2024-05-13 23:02:21', 4, 5, 41),
(1007, '2024-05-13 23:02:21', 1, 2, 41),
(1008, '2024-05-13 23:02:22', 5, 7, 41),
(1009, '2024-05-13 23:02:22', 2, 5, 41),
(1010, '2024-05-13 23:02:24', 3, 2, 41),
(1011, '2024-05-13 23:02:25', 5, 7, 41),
(1012, '2024-05-13 23:02:25', 2, 5, 41),
(1013, '2024-05-13 23:02:27', 7, 5, 41),
(1014, '2024-05-13 23:02:27', 5, 6, 41),
(1015, '2024-05-13 23:02:27', 3, 2, 41),
(1016, '2024-05-13 23:02:30', 3, 2, 41),
(1017, '2024-05-13 23:02:31', 7, 5, 41),
(1018, '2024-05-13 23:02:31', 5, 6, 41),
(1019, '2024-05-13 23:02:31', 2, 4, 41),
(1020, '2024-05-13 23:02:33', 7, 5, 41),
(1021, '2024-05-13 23:02:33', 1, 2, 41),
(1022, '2024-05-13 23:02:34', 6, 8, 41),
(1023, '2024-05-13 23:02:34', 2, 4, 41),
(1024, '2024-05-13 23:02:35', 5, 6, 41),
(1025, '2024-05-13 23:02:36', 8, 10, 41),
(1026, '2024-05-13 23:02:39', 4, 5, 41),
(1027, '2024-05-13 23:02:39', 1, 2, 41),
(1028, '2024-05-13 23:02:40', 3, 2, 41),
(1029, '2024-05-13 23:02:40', 2, 4, 41),
(1030, '2024-05-13 23:02:40', 2, 5, 41),
(1031, '2024-05-13 23:02:41', 5, 6, 41),
(1032, '2024-05-13 23:02:42', 5, 7, 41),
(1033, '2024-05-13 23:02:42', 4, 5, 41),
(1034, '2024-05-13 23:02:42', 1, 2, 41),
(1035, '2024-05-13 23:02:43', 2, 4, 41),
(1036, '2024-05-13 23:02:46', 3, 2, 41),
(1037, '2024-05-13 23:02:48', 6, 8, 41),
(1038, '2024-05-13 23:02:48', 4, 5, 41),
(1039, '2024-05-13 23:02:48', 3, 2, 41),
(1040, '2024-05-13 23:02:49', 8, 10, 41),
(1041, '2024-05-13 23:02:49', 2, 4, 41),
(1042, '2024-05-13 23:02:51', 1, 2, 41),
(1043, '2024-05-13 23:02:52', 5, 6, 41),
(1044, '2024-05-13 23:02:52', 2, 4, 41),
(1045, '2024-05-13 23:02:53', 2, 5, 41),
(1046, '2024-05-13 23:02:53', 3, 2, 41),
(1047, '2024-05-13 23:02:54', 3, 2, 41),
(1048, '2024-05-13 23:02:57', 1, 2, 41),
(1049, '2024-05-13 23:02:58', 5, 6, 41),
(1050, '2024-05-13 23:02:58', 2, 4, 41),
(1051, '2024-05-13 23:02:59', 2, 5, 41),
(1052, '2024-05-13 23:03:00', 3, 2, 41),
(1053, '2024-05-13 23:03:01', 2, 4, 41),
(1054, '2024-05-13 23:03:03', 8, 10, 41),
(1055, '2024-05-13 23:03:03', 2, 4, 41),
(1056, '2024-05-13 23:03:03', 1, 2, 41),
(1057, '2024-05-13 23:03:04', 2, 4, 41),
(1058, '2024-05-13 23:03:05', 6, 8, 41),
(1059, '2024-05-13 23:03:06', 4, 5, 41),
(1060, '2024-05-13 23:03:09', 5, 6, 41),
(1061, '2024-05-13 23:03:09', 4, 5, 41),
(1062, '2024-05-13 23:03:09', 1, 2, 41),
(1063, '2024-05-13 23:03:10', 2, 5, 41),
(1064, '2024-05-13 23:03:10', 2, 4, 41),
(1065, '2024-05-13 23:03:11', 4, 5, 41),
(1066, '2024-05-13 23:03:12', 5, 7, 41),
(1067, '2024-05-13 23:03:12', 4, 5, 41),
(1068, '2024-05-13 23:03:13', 5, 7, 41),
(1069, '2024-05-13 23:03:13', 2, 4, 41),
(1070, '2024-05-13 23:03:15', 1, 2, 41),
(1071, '2024-05-13 23:03:16', 6, 8, 41),
(1072, '2024-05-13 23:03:16', 5, 6, 41),
(1073, '2024-05-13 23:03:18', 4, 5, 41),
(1074, '2024-05-13 23:03:20', 8, 10, 41),
(1075, '2024-05-13 23:03:21', 1, 2, 41),
(1076, '2024-05-13 23:03:22', 5, 6, 41),
(1077, '2024-05-13 23:03:22', 2, 5, 41),
(1078, '2024-05-13 23:03:24', 3, 2, 41),
(1079, '2024-05-13 23:03:27', 3, 2, 41),
(1080, '2024-05-13 23:03:28', 7, 5, 41),
(1081, '2024-05-13 23:03:28', 5, 6, 41),
(1082, '2024-05-13 23:03:28', 2, 5, 41),
(1083, '2024-05-13 23:03:30', 3, 2, 41),
(1084, '2024-05-13 23:03:31', 8, 10, 41),
(1085, '2024-05-13 23:03:31', 2, 4, 41),
(1086, '2024-05-13 23:03:32', 5, 6, 41),
(1087, '2024-05-13 23:03:33', 3, 2, 41),
(1088, '2024-05-13 23:03:35', 6, 8, 41),
(1089, '2024-05-13 23:03:36', 1, 2, 41),
(1090, '2024-05-13 23:03:37', 2, 5, 41),
(1091, '2024-05-13 23:03:37', 2, 4, 41),
(1092, '2024-05-13 23:03:38', 5, 6, 41),
(1093, '2024-05-13 23:03:39', 6, 8, 41),
(1094, '2024-05-13 23:03:39', 1, 2, 41),
(1095, '2024-05-13 23:03:40', 2, 4, 41),
(1096, '2024-05-13 23:03:41', 3, 2, 41),
(1097, '2024-05-13 23:03:43', 2, 4, 41),
(1098, '2024-05-13 23:03:45', 4, 5, 41),
(1099, '2024-05-13 23:03:45', 3, 2, 41),
(1100, '2024-05-13 23:03:46', 2, 4, 41),
(1101, '2024-05-13 23:03:48', 4, 5, 41),
(1102, '2024-05-13 23:03:48', 5, 7, 41),
(1103, '2024-05-13 23:03:48', 3, 2, 41),
(1104, '2024-05-13 23:03:49', 2, 4, 41),
(1105, '2024-05-13 23:03:50', 3, 2, 41),
(1106, '2024-05-13 23:03:50', 8, 10, 41),
(1107, '2024-05-13 23:03:51', 3, 2, 41),
(1108, '2024-05-13 23:03:54', 2, 5, 41),
(1109, '2024-05-13 23:03:54', 8, 10, 41),
(1110, '2024-05-13 23:03:54', 4, 5, 41),
(1111, '2024-05-13 23:03:55', 2, 4, 41),
(1112, '2024-05-13 23:03:58', 5, 6, 41),
(1113, '2024-05-13 23:03:58', 2, 4, 41),
(1114, '2024-05-13 23:04:00', 1, 2, 41),
(1115, '2024-05-13 23:04:01', 2, 4, 41),
(1116, '2024-05-13 23:04:03', 2, 5, 41),
(1117, '2024-05-13 23:04:03', 1, 2, 41),
(1118, '2024-05-13 23:04:04', 5, 6, 41),
(1119, '2024-05-13 23:04:04', 5, 6, 41),
(1120, '2024-05-13 23:04:06', 4, 5, 41),
(1121, '2024-05-13 23:04:09', 5, 7, 41),
(1122, '2024-05-13 23:04:09', 1, 2, 41),
(1123, '2024-05-13 23:04:10', 2, 4, 41),
(1124, '2024-05-13 23:04:11', 6, 8, 41),
(1125, '2024-05-13 23:04:11', 6, 8, 41),
(1126, '2024-05-13 23:04:12', 1, 2, 41),
(1127, '2024-05-13 23:04:13', 2, 4, 41),
(1128, '2024-05-13 23:04:16', 3, 2, 41),
(1129, '2024-05-13 23:04:18', 4, 5, 41),
(1130, '2024-05-13 23:04:18', 3, 2, 41),
(1131, '2024-05-13 23:04:19', 2, 4, 41),
(1132, '2024-05-13 23:04:21', 5, 7, 41),
(1133, '2024-05-13 23:04:25', 2, 5, 41),
(1134, '2024-05-13 23:04:26', 2, 4, 41),
(1135, '2024-05-13 23:04:26', 8, 10, 41),
(1136, '2024-05-13 23:04:26', 8, 10, 41),
(1137, '2024-05-13 23:04:27', 4, 5, 41),
(1138, '2024-05-13 23:04:27', 1, 2, 41),
(1139, '2024-05-13 23:04:28', 5, 7, 41),
(1140, '2024-05-13 23:04:28', 2, 4, 41),
(1141, '2024-05-13 23:04:30', 5, 7, 41),
(1142, '2024-05-13 23:04:33', 3, 2, 41),
(1143, '2024-05-13 23:04:36', 3, 2, 41),
(1144, '2024-05-13 23:04:37', 2, 4, 41),
(1145, '2024-05-13 23:04:39', 3, 2, 41),
(1146, '2024-05-13 23:04:45', 4, 5, 41),
(1147, '2024-05-13 23:04:45', 3, 2, 41),
(1148, '2024-05-13 23:04:46', 2, 5, 41),
(1149, '2024-05-13 23:04:46', 2, 4, 41),
(1150, '2024-05-13 23:04:48', 3, 2, 41),
(1151, '2024-05-13 23:04:50', 2, 4, 41),
(1152, '2024-05-13 23:04:55', 4, 5, 41),
(1153, '2024-05-13 23:04:56', 5, 6, 41),
(1154, '2024-05-13 23:04:56', 2, 4, 41),
(1155, '2024-05-13 23:04:57', 5, 6, 41),
(1156, '2024-05-13 23:04:58', 4, 5, 41),
(1157, '2024-05-13 23:04:58', 5, 7, 41),
(1158, '2024-05-13 23:04:59', 2, 4, 41),
(1159, '2024-05-13 23:05:04', 4, 5, 41),
(1160, '2024-05-13 23:05:11', 3, 2, 41),
(1161, '2024-05-13 23:05:14', 5, 6, 41),
(1162, '2024-05-13 23:05:21', 2, 4, 41),
(1163, '2024-05-13 23:05:29', 4, 5, 41),
(1164, '2024-05-13 23:05:39', 5, 6, 41),
(1165, '2024-05-13 23:05:46', 6, 8, 41),
(1166, '2024-05-13 23:06:01', 8, 10, 41),
(1167, '2024-05-13 23:06:17', 1, 2, NULL),
(1168, '2024-05-13 23:06:23', 1, 2, NULL),
(1169, '2024-05-13 23:06:26', 1, 2, NULL),
(1170, '2024-05-13 23:06:30', 2, 5, NULL),
(1171, '2024-05-13 23:06:32', 3, 2, NULL),
(1172, '2024-05-13 23:06:35', 3, 2, NULL),
(1173, '2024-05-13 23:06:36', 2, 5, NULL),
(1174, '2024-05-13 23:06:36', 2, 4, NULL),
(1175, '2024-05-13 23:06:38', 3, 2, NULL),
(1176, '2024-05-13 23:06:41', 3, 2, NULL),
(1177, '2024-05-13 23:06:43', 3, 2, NULL),
(1178, '2024-05-13 23:06:44', 4, 5, NULL),
(1179, '2024-05-13 23:06:45', 2, 5, NULL),
(1180, '2024-05-13 23:06:46', 5, 6, NULL),
(1181, '2024-05-13 23:06:47', 5, 7, NULL),
(1182, '2024-05-13 23:06:47', 3, 2, NULL),
(1183, '2024-05-13 23:06:48', 2, 5, NULL),
(1184, '2024-05-13 23:06:48', 2, 4, NULL),
(1185, '2024-05-13 23:06:50', 1, 2, NULL),
(1186, '2024-05-13 23:06:53', 6, 8, NULL),
(1187, '2024-05-13 23:06:53', 1, 2, NULL),
(1188, '2024-05-13 23:06:54', 2, 5, NULL),
(1189, '2024-05-13 23:06:56', 2, 5, NULL),
(1190, '2024-05-13 23:06:56', 8, 9, NULL),
(1191, '2024-05-13 23:06:56', 4, 5, NULL),
(1192, '2024-05-13 23:06:57', 2, 4, NULL),
(1193, '2024-05-13 23:06:58', 5, 6, NULL),
(1194, '2024-05-13 23:06:58', 3, 2, NULL),
(1195, '2024-05-13 23:07:00', 2, 4, NULL),
(1196, '2024-05-13 23:07:02', 7, 5, NULL),
(1197, '2024-05-13 23:07:05', 5, 7, NULL),
(1198, '2024-05-13 23:07:05', 6, 8, NULL),
(1199, '2024-05-13 23:07:05', 4, 5, NULL),
(1200, '2024-05-13 23:07:05', 1, 2, NULL),
(1201, '2024-05-13 23:07:06', 2, 5, NULL),
(1202, '2024-05-13 23:07:07', 3, 2, NULL),
(1203, '2024-05-13 23:07:08', 9, 7, NULL),
(1204, '2024-05-13 23:07:08', 8, 9, NULL),
(1205, '2024-05-13 23:07:08', 5, 7, NULL),
(1206, '2024-05-13 23:07:08', 4, 5, NULL),
(1207, '2024-05-13 23:07:09', 3, 2, NULL),
(1208, '2024-05-13 23:07:09', 3, 2, NULL),
(1209, '2024-05-13 23:07:11', 2, 5, NULL),
(1210, '2024-05-13 23:07:11', 3, 2, NULL),
(1211, '2024-05-13 23:07:15', 2, 4, NULL),
(1212, '2024-05-13 23:07:17', 1, 2, NULL),
(1213, '2024-05-13 23:07:18', 5, 6, NULL),
(1214, '2024-05-13 23:07:19', 2, 4, NULL),
(1215, '2024-05-13 23:07:19', 3, 2, NULL),
(1216, '2024-05-13 23:07:20', 7, 5, NULL),
(1217, '2024-05-13 23:07:20', 2, 5, NULL),
(1218, '2024-05-13 23:07:20', 9, 7, NULL),
(1219, '2024-05-13 23:07:20', 1, 2, NULL),
(1220, '2024-05-13 23:07:21', 5, 6, NULL),
(1221, '2024-05-13 23:07:22', 2, 5, NULL),
(1222, '2024-05-13 23:07:23', 7, 5, NULL),
(1223, '2024-05-13 23:07:23', 5, 7, NULL),
(1224, '2024-05-13 23:07:23', 7, 5, NULL),
(1225, '2024-05-13 23:07:23', 4, 5, NULL),
(1226, '2024-05-13 23:07:23', 3, 2, NULL),
(1227, '2024-05-13 23:07:24', 2, 5, NULL),
(1228, '2024-05-13 23:07:27', 4, 5, NULL),
(1229, '2024-05-13 23:07:27', 5, 7, NULL),
(1230, '2024-05-13 23:07:28', 6, 8, NULL),
(1231, '2024-05-13 23:07:30', 2, 5, NULL),
(1232, '2024-05-13 23:07:32', 2, 5, NULL),
(1233, '2024-05-13 23:07:32', 3, 2, NULL),
(1234, '2024-05-13 23:07:33', 5, 6, NULL),
(1235, '2024-05-13 23:07:33', 3, 2, NULL),
(1236, '2024-05-13 23:07:33', 5, 6, NULL),
(1237, '2024-05-13 23:07:33', 5, 6, NULL),
(1238, '2024-05-13 23:07:33', 2, 5, NULL),
(1239, '2024-05-13 23:07:33', 2, 4, NULL),
(1240, '2024-05-13 23:07:35', 7, 5, NULL),
(1241, '2024-05-13 23:07:35', 3, 2, NULL),
(1242, '2024-05-13 23:07:35', 3, 2, NULL),
(1243, '2024-05-13 23:07:38', 7, 5, NULL),
(1244, '2024-05-13 23:07:38', 1, 2, NULL),
(1245, '2024-05-13 23:07:40', 3, 2, NULL),
(1246, '2024-05-13 23:07:40', 6, 8, NULL),
(1247, '2024-05-13 23:07:40', 6, 8, NULL),
(1248, '2024-05-13 23:07:40', 6, 8, NULL),
(1249, '2024-05-13 23:07:40', 5, 6, NULL),
(1250, '2024-05-13 23:07:41', 5, 7, NULL),
(1251, '2024-05-13 23:07:41', 4, 5, NULL),
(1252, '2024-05-13 23:07:41', 3, 2, NULL),
(1253, '2024-05-13 23:07:42', 5, 6, NULL);
INSERT INTO `medicoespassagem` (`IDMedição`, `DataHora`, `SalaOrigem`, `SalaDestino`, `IDExperiencia`) VALUES
(1254, '2024-05-13 23:07:42', 7, 5, NULL),
(1255, '2024-05-13 23:07:42', 2, 4, NULL),
(1256, '2024-05-13 23:07:43', 2, 4, NULL),
(1257, '2024-05-13 23:07:43', 8, 9, NULL),
(1258, '2024-05-13 23:07:43', 5, 6, NULL),
(1259, '2024-05-13 23:07:45', 2, 4, NULL),
(1260, '2024-05-13 23:07:45', 2, 4, NULL),
(1261, '2024-05-13 23:07:47', 1, 2, NULL),
(1262, '2024-05-13 23:07:48', 3, 2, NULL),
(1263, '2024-05-13 23:07:48', 2, 4, NULL),
(1264, '2024-05-13 23:07:49', 6, 8, NULL),
(1265, '2024-05-13 23:07:50', 2, 4, NULL),
(1266, '2024-05-13 23:07:50', 4, 5, NULL),
(1267, '2024-05-13 23:07:50', 3, 2, NULL),
(1268, '2024-05-13 23:07:51', 4, 5, NULL),
(1269, '2024-05-13 23:07:51', 5, 6, NULL),
(1270, '2024-05-13 23:07:52', 5, 6, NULL),
(1271, '2024-05-13 23:07:53', 4, 5, NULL),
(1272, '2024-05-13 23:07:53', 4, 5, NULL),
(1273, '2024-05-13 23:07:53', 1, 2, NULL),
(1274, '2024-05-13 23:07:54', 5, 7, NULL),
(1275, '2024-05-13 23:07:54', 2, 5, NULL),
(1276, '2024-05-13 23:07:55', 8, 10, NULL),
(1277, '2024-05-13 23:07:55', 9, 7, NULL),
(1278, '2024-05-13 23:07:56', 7, 5, NULL),
(1279, '2024-05-13 23:07:56', 4, 5, NULL),
(1280, '2024-05-13 23:07:56', 3, 2, NULL),
(1281, '2024-05-13 23:07:58', 4, 5, NULL),
(1282, '2024-05-13 23:07:59', 6, 8, NULL),
(1283, '2024-05-13 23:07:59', 1, 2, NULL),
(1284, '2024-05-13 23:08:00', 2, 5, NULL),
(1285, '2024-05-13 23:08:00', 2, 4, NULL),
(1286, '2024-05-13 23:08:01', 2, 5, NULL),
(1287, '2024-05-13 23:08:02', 8, 9, NULL),
(1288, '2024-05-13 23:08:02', 3, 2, NULL),
(1289, '2024-05-13 23:08:03', 3, 2, NULL),
(1290, '2024-05-13 23:08:03', 5, 6, NULL),
(1291, '2024-05-13 23:08:03', 2, 4, NULL),
(1292, '2024-05-13 23:08:04', 5, 7, NULL),
(1293, '2024-05-13 23:08:04', 8, 10, NULL),
(1294, '2024-05-13 23:08:05', 1, 2, NULL),
(1295, '2024-05-13 23:08:06', 3, 2, NULL),
(1296, '2024-05-13 23:08:06', 5, 6, NULL),
(1297, '2024-05-13 23:08:06', 2, 4, NULL),
(1298, '2024-05-13 23:08:07', 3, 2, NULL),
(1299, '2024-05-13 23:08:08', 4, 5, NULL),
(1300, '2024-05-13 23:08:08', 3, 2, NULL),
(1301, '2024-05-13 23:08:09', 3, 2, NULL),
(1302, '2024-05-13 23:08:09', 7, 5, NULL),
(1303, '2024-05-13 23:08:10', 7, 5, NULL),
(1304, '2024-05-13 23:08:10', 6, 8, NULL),
(1305, '2024-05-13 23:10:34', 8, 10, NULL),
(1306, '2024-05-13 23:10:34', 4, 5, NULL),
(1307, '2024-05-13 23:10:35', 2, 4, NULL),
(1308, '2024-05-13 23:10:35', 6, 8, NULL),
(1309, '2024-05-13 23:10:35', 5, 3, NULL),
(1310, '2024-05-13 23:10:36', 8, 9, NULL),
(1311, '2024-05-13 23:10:37', 5, 6, NULL),
(1312, '2024-05-13 23:10:38', 4, 5, NULL),
(1313, '2024-05-13 23:10:38', 5, 6, NULL),
(1314, '2024-05-13 23:10:38', 8, 9, NULL),
(1315, '2024-05-13 23:10:39', 3, 2, NULL),
(1316, '2024-05-13 23:10:40', 5, 3, NULL),
(1317, '2024-05-13 23:10:41', 2, 5, NULL),
(1318, '2024-05-13 23:10:41', 5, 6, NULL),
(1319, '2024-05-13 23:10:41', 5, 3, NULL),
(1320, '2024-05-13 23:10:41', 5, 7, NULL),
(1321, '2024-05-13 23:10:43', 4, 5, NULL),
(1322, '2024-05-13 23:10:44', 3, 2, NULL),
(1323, '2024-05-13 23:10:44', 9, 7, NULL),
(1324, '2024-05-13 23:10:44', 5, 7, NULL),
(1325, '2024-05-13 23:10:44', 6, 8, NULL),
(1326, '2024-05-13 23:10:44', 3, 2, NULL),
(1327, '2024-05-13 23:10:44', 5, 3, NULL),
(1328, '2024-05-13 23:10:45', 6, 8, NULL),
(1329, '2024-05-13 23:10:47', 8, 10, NULL),
(1330, '2024-05-13 23:10:48', 3, 2, NULL),
(1331, '2024-05-13 23:10:49', 8, 9, NULL),
(1332, '2024-05-13 23:10:53', 2, 5, NULL),
(1333, '2024-05-13 23:10:53', 5, 6, NULL),
(1334, '2024-05-13 23:10:54', 2, 4, NULL),
(1335, '2024-05-13 23:10:55', 2, 4, NULL),
(1336, '2024-05-13 23:10:57', 7, 5, NULL),
(1337, '2024-05-13 23:10:58', 2, 4, NULL),
(1338, '2024-05-13 23:10:59', 7, 5, NULL),
(1339, '2024-05-13 23:10:59', 7, 5, NULL),
(1340, '2024-05-13 23:11:00', 6, 8, NULL),
(1341, '2024-05-13 23:11:00', 5, 7, NULL),
(1342, '2024-05-13 23:11:02', 4, 5, NULL),
(1343, '2024-05-13 23:11:03', 5, 6, NULL),
(1344, '2024-05-13 23:11:03', 4, 5, NULL),
(1345, '2024-05-13 23:11:06', 5, 7, NULL),
(1346, '2024-05-13 23:11:06', 4, 5, NULL),
(1347, '2024-05-13 23:11:09', 5, 3, NULL),
(1348, '2024-05-13 23:11:10', 5, 6, NULL),
(1349, '2024-05-13 23:11:12', 5, 6, NULL),
(1350, '2024-05-13 23:11:12', 3, 2, NULL),
(1351, '2024-05-13 23:11:16', 7, 5, NULL),
(1352, '2024-05-13 23:11:19', 6, 8, NULL),
(1353, '2024-05-13 23:11:21', 7, 5, NULL),
(1354, '2024-05-13 23:11:22', 2, 4, NULL),
(1355, '2024-05-13 23:11:26', 5, 6, NULL),
(1356, '2024-05-13 23:11:30', 4, 5, NULL),
(1357, '2024-05-13 23:11:31', 5, 3, NULL),
(1358, '2024-05-13 23:11:33', 6, 8, NULL),
(1359, '2024-05-13 23:11:34', 8, 10, NULL),
(1360, '2024-05-13 23:11:34', 3, 2, NULL),
(1361, '2024-05-13 23:11:40', 5, 6, NULL),
(1362, '2024-05-13 23:11:45', 2, 4, NULL),
(1363, '2024-05-13 23:11:54', 4, 5, NULL),
(1364, '2024-05-13 23:11:57', 5, 7, NULL),
(1365, '2024-05-13 23:12:12', 7, 5, NULL),
(1366, '2000-01-01 00:00:00', 0, 0, 41),
(1367, '2024-05-13 23:12:25', 1, 3, 41),
(1368, '2024-05-13 23:12:28', 3, 2, 41),
(1369, '2024-05-13 23:12:31', 1, 2, 41),
(1370, '2024-05-13 23:12:34', 1, 2, 41),
(1371, '2024-05-13 23:12:37', 1, 2, 41),
(1372, '2024-05-13 23:12:38', 2, 4, 41),
(1373, '2024-05-13 23:12:40', 1, 2, 41),
(1374, '2024-05-13 23:12:40', 1, 3, 41),
(1375, '2024-05-13 23:12:43', 1, 3, 41),
(1376, '2024-05-13 23:12:43', 3, 2, 41),
(1377, '2024-05-13 23:12:44', 2, 5, 41),
(1378, '2024-05-13 23:12:44', 2, 4, 41),
(1379, '2024-05-13 23:12:46', 4, 5, 41),
(1380, '2024-05-13 23:12:46', 1, 3, 41),
(1381, '2024-05-13 23:12:46', 3, 2, 41),
(1382, '2024-05-13 23:12:47', 2, 4, 41),
(1383, '2024-05-13 23:12:49', 1, 3, 41),
(1384, '2024-05-13 23:12:50', 2, 4, 41),
(1385, '2024-05-13 23:12:52', 4, 5, 41),
(1386, '2024-05-13 23:12:53', 2, 4, 41),
(1387, '2024-05-13 23:12:54', 5, 6, 41),
(1388, '2024-05-13 23:12:55', 4, 5, 41),
(1389, '2024-05-13 23:12:55', 5, 7, 41),
(1390, '2024-05-13 23:12:55', 1, 2, 41),
(1391, '2024-05-13 23:12:55', 1, 3, 41),
(1392, '2024-05-13 23:12:56', 5, 6, 41),
(1393, '2024-05-13 23:12:58', 4, 5, 41),
(1394, '2024-05-13 23:12:58', 5, 7, 41),
(1395, '2024-05-13 23:12:59', 3, 2, 41),
(1396, '2024-05-13 23:12:59', 2, 5, 41),
(1397, '2024-05-13 23:13:01', 6, 8, 41),
(1398, '2024-05-13 23:13:01', 5, 7, 41),
(1399, '2024-05-13 23:13:01', 4, 5, 41),
(1400, '2024-05-13 23:13:01', 1, 2, 41),
(1401, '2024-05-13 23:13:04', 6, 8, 41),
(1402, '2024-05-13 23:13:04', 1, 2, 41),
(1403, '2024-05-13 23:13:07', 8, 9, 41),
(1404, '2024-05-13 23:13:07', 1, 3, 41),
(1405, '2024-05-13 23:13:07', 1, 2, 41),
(1406, '2024-05-13 23:13:08', 2, 5, 41),
(1407, '2024-05-13 23:13:09', 2, 4, 41),
(1408, '2024-05-13 23:13:09', 5, 3, 41),
(1409, '2024-05-13 23:13:10', 7, 5, 41),
(1410, '2024-05-13 23:13:10', 3, 2, 41),
(1411, '2024-05-13 23:13:10', 1, 3, 41),
(1412, '2024-05-13 23:13:11', 5, 3, 41),
(1413, '2024-05-13 23:13:11', 2, 4, 41),
(1414, '2024-05-13 23:13:12', 3, 2, 41),
(1415, '2024-05-13 23:13:13', 5, 7, 41),
(1416, '2024-05-13 23:13:13', 7, 5, 41),
(1417, '2024-05-13 23:13:13', 1, 3, 41),
(1418, '2024-05-13 23:13:13', 3, 2, 41),
(1419, '2024-05-13 23:13:14', 3, 2, 41),
(1420, '2024-05-13 23:13:16', 8, 10, 41),
(1421, '2024-05-13 23:13:16', 7, 5, 41),
(1422, '2024-05-13 23:13:16', 1, 3, 41),
(1423, '2024-05-13 23:13:17', 4, 5, 41),
(1424, '2024-05-13 23:13:17', 2, 5, 41),
(1425, '2024-05-13 23:13:19', 4, 5, 41),
(1426, '2024-05-13 23:13:20', 2, 5, 41),
(1427, '2024-05-13 23:13:20', 2, 4, 41),
(1428, '2024-05-13 23:13:22', 2, 4, 41),
(1429, '2024-05-13 23:13:22', 5, 7, 41),
(1430, '2024-05-13 23:13:22', 1, 2, 41),
(1431, '2024-05-13 23:13:22', 1, 3, 41),
(1432, '2024-05-13 23:13:23', 5, 3, 41),
(1433, '2024-05-13 23:13:25', 3, 2, 41),
(1434, '2024-05-13 23:13:25', 1, 3, 41),
(1435, '2024-05-13 23:13:26', 5, 3, 41),
(1436, '2024-05-13 23:13:26', 3, 2, 41),
(1437, '2024-05-13 23:13:26', 2, 5, 41),
(1438, '2024-05-13 23:13:27', 5, 3, 41),
(1439, '2024-05-13 23:13:27', 2, 5, 41),
(1440, '2024-05-13 23:13:27', 5, 3, 41),
(1441, '2024-05-13 23:13:28', 7, 5, 41),
(1442, '2024-05-13 23:13:28', 4, 5, 41),
(1443, '2024-05-13 23:13:28', 1, 3, 41),
(1444, '2024-05-13 23:13:28', 3, 2, 41),
(1445, '2024-05-13 23:13:29', 3, 2, 41),
(1446, '2024-05-13 23:13:30', 3, 2, 41),
(1447, '2024-05-13 23:13:30', 3, 10, 41),
(1448, '2024-05-13 23:13:30', 4, 5, 41),
(1449, '2024-05-13 23:13:30', 3, 2, 41),
(1450, '2024-05-13 23:13:31', 5, 7, 41),
(1451, '2024-05-13 23:13:31', 1, 3, 41),
(1452, '2024-05-13 23:13:32', 2, 4, 41),
(1453, '2024-05-13 23:13:37', 5, 3, 41),
(1454, '2024-05-13 23:13:37', 7, 5, 41),
(1455, '2024-05-13 23:13:37', 1, 2, 41),
(1456, '2024-05-13 23:13:38', 5, 3, 41),
(1457, '2024-05-13 23:13:38', 2, 5, 41),
(1458, '2024-05-13 23:13:39', 2, 4, 41),
(1459, '2024-05-13 23:13:39', 2, 5, 41),
(1460, '2024-05-13 23:13:40', 3, 2, 41),
(1461, '2024-05-13 23:13:40', 5, 6, 41),
(1462, '2024-05-13 23:13:40', 5, 7, 41),
(1463, '2024-05-13 23:13:40', 4, 5, 41),
(1464, '2024-05-13 23:13:40', 1, 2, 41),
(1465, '2024-05-13 23:13:41', 3, 2, 41),
(1466, '2024-05-13 23:13:41', 2, 5, 41),
(1467, '2024-05-13 23:13:42', 5, 7, 41),
(1468, '2024-05-13 23:13:43', 2, 5, 41),
(1469, '2024-05-13 23:13:43', 2, 5, 41),
(1470, '2024-05-13 23:13:43', 5, 7, 41),
(1471, '2024-05-13 23:13:43', 1, 2, 41),
(1472, '2024-05-13 23:13:44', 5, 7, 41),
(1473, '2024-05-13 23:13:46', 5, 7, 41),
(1474, '2024-05-13 23:13:46', 7, 5, 41),
(1475, '2024-05-13 23:13:46', 1, 2, 41),
(1476, '2024-05-13 23:13:46', 1, 3, 41),
(1477, '2024-05-13 23:13:47', 4, 5, 41),
(1478, '2024-05-13 23:13:47', 6, 8, 41),
(1479, '2024-05-13 23:13:49', 3, 2, 41),
(1480, '2024-05-13 23:13:50', 8, 9, 41),
(1481, '2024-05-13 23:13:50', 2, 5, 41),
(1482, '2024-05-13 23:13:50', 2, 4, 41),
(1483, '2024-05-13 23:13:51', 2, 4, 41),
(1484, '2024-05-13 23:13:52', 1, 2, 41),
(1485, '2024-05-13 23:13:52', 1, 3, 41),
(1486, '2024-05-13 23:13:53', 5, 6, 41),
(1487, '2024-05-13 23:13:53', 2, 5, 41),
(1488, '2024-05-13 23:13:53', 5, 7, 41),
(1489, '2024-05-13 23:13:55', 7, 5, 41),
(1490, '2024-05-13 23:13:55', 3, 2, 41),
(1491, '2024-05-13 23:13:55', 1, 3, 41),
(1492, '2024-05-13 23:13:56', 5, 3, 41),
(1493, '2024-05-13 23:13:56', 2, 5, 41),
(1494, '2024-05-13 23:13:57', 5, 6, 41),
(1495, '2024-05-13 23:13:57', 7, 5, 41),
(1496, '2024-05-13 23:13:58', 7, 5, 41),
(1497, '2024-05-13 23:13:58', 4, 5, 41),
(1498, '2024-05-13 23:13:59', 4, 5, 41),
(1499, '2024-05-13 23:13:59', 3, 2, 41),
(1500, '2024-05-13 23:13:59', 7, 5, 41),
(1501, '2024-05-13 23:13:59', 2, 5, 41),
(1502, '2024-05-13 23:14:00', 6, 8, 41),
(1503, '2024-05-13 23:14:01', 7, 5, 41),
(1504, '2024-05-13 23:14:01', 5, 7, 41),
(1505, '2024-05-13 23:14:01', 5, 7, 41),
(1506, '2024-05-13 23:14:01', 1, 2, 41),
(1507, '2024-05-13 23:14:01', 1, 3, 41),
(1508, '2024-05-13 23:14:02', 5, 7, 41),
(1509, '2024-05-13 23:14:02', 2, 5, 41),
(1510, '2024-05-13 23:14:03', 8, 9, 41),
(1511, '2024-05-13 23:14:03', 5, 6, 41),
(1512, '2024-05-13 23:14:04', 6, 8, 41),
(1513, '2024-05-13 23:14:04', 5, 7, 41),
(1514, '2024-05-13 23:14:05', 5, 3, 41),
(1515, '2024-05-13 23:14:05', 2, 5, 41),
(1516, '2024-05-13 23:14:05', 2, 4, 41),
(1517, '2024-05-13 23:14:06', 5, 3, 41),
(1518, '2024-05-13 23:14:07', 5, 3, 41),
(1519, '2024-05-13 23:14:07', 1, 2, 41),
(1520, '2024-05-13 23:14:08', 3, 2, 41),
(1521, '2024-05-13 23:14:08', 7, 5, 41),
(1522, '2024-05-13 23:14:09', 5, 6, 41),
(1523, '2024-05-13 23:14:09', 2, 4, 41),
(1524, '2024-05-13 23:14:09', 5, 6, 41),
(1525, '2024-05-13 23:14:09', 3, 2, 41),
(1526, '2024-05-13 23:14:10', 6, 8, 41),
(1527, '2024-05-13 23:14:10', 3, 2, 41),
(1528, '2024-05-13 23:14:10', 1, 2, 41),
(1529, '2024-05-13 23:14:11', 2, 4, 41),
(1530, '2024-05-13 23:14:12', 5, 3, 41),
(1531, '2024-05-13 23:14:13', 4, 5, 41),
(1532, '2024-05-13 23:14:13', 1, 2, 41),
(1533, '2024-05-13 23:14:13', 1, 3, 41),
(1534, '2024-05-13 23:14:15', 3, 2, 41),
(1535, '2024-05-13 23:14:16', 6, 8, 41),
(1536, '2024-05-13 23:14:16', 7, 5, 41),
(1537, '2024-05-13 23:14:16', 7, 5, 41),
(1538, '2024-05-13 23:14:16', 6, 8, 41),
(1539, '2024-05-13 23:14:16', 1, 3, 41),
(1540, '2024-05-13 23:14:17', 4, 5, 41),
(1541, '2024-05-13 23:14:17', 7, 5, 41),
(1542, '2024-05-13 23:14:18', 2, 4, 41),
(1543, '2024-05-13 23:14:18', 5, 3, 41),
(1544, '2024-05-13 23:14:19', 8, 10, 41),
(1545, '2024-05-13 23:14:19', 8, 9, 41),
(1546, '2024-05-13 23:14:19', 7, 5, 41),
(1547, '2024-05-13 23:14:19', 8, 9, 41),
(1548, '2024-05-13 23:14:19', 4, 5, 41),
(1549, '2024-05-13 23:14:19', 1, 3, 41),
(1550, '2024-05-13 23:14:20', 2, 4, 41),
(1551, '2024-05-13 23:14:20', 5, 7, 41),
(1552, '2024-05-13 23:14:20', 2, 5, 41),
(1553, '2024-05-13 23:14:21', 3, 2, 41),
(1554, '2024-05-13 23:14:22', 5, 7, 41),
(1555, '2024-05-13 23:14:22', 2, 5, 41),
(1556, '2024-05-13 23:14:22', 1, 3, 41),
(1557, '2024-05-13 23:14:22', 5, 7, 41),
(1558, '2024-05-13 23:14:23', 3, 2, 41),
(1559, '2024-05-13 23:14:23', 5, 6, 41),
(1560, '2024-05-13 23:14:23', 2, 5, 41),
(1561, '2024-05-13 23:14:25', 8, 10, 41),
(1562, '2024-05-13 23:14:25', 5, 7, 41),
(1563, '2024-05-13 23:14:25', 2, 4, 41),
(1564, '2024-05-13 23:14:25', 1, 3, 41),
(1565, '2024-05-13 23:14:25', 3, 2, 41),
(1566, '2024-05-13 23:14:26', 4, 5, 41),
(1567, '2024-05-13 23:14:26', 5, 3, 41),
(1568, '2024-05-13 23:14:26', 5, 6, 41),
(1569, '2024-05-13 23:14:26', 2, 5, 41),
(1570, '2024-05-13 23:14:27', 5, 3, 41),
(1571, '2024-05-13 23:14:28', 4, 5, 41),
(1572, '2024-05-13 23:14:28', 3, 2, 41),
(1573, '2024-05-13 23:14:29', 5, 7, 41),
(1574, '2024-05-13 23:14:29', 3, 2, 41),
(1575, '2024-05-13 23:14:30', 3, 2, 41),
(1576, '2024-05-13 23:14:30', 6, 8, 41),
(1577, '2024-05-13 23:14:31', 5, 7, 41),
(1578, '2024-05-13 23:14:31', 1, 2, 41),
(1579, '2024-05-13 23:14:31', 1, 3, 41),
(1580, '2024-05-13 23:14:32', 2, 4, 41),
(1581, '2024-05-13 23:14:33', 6, 8, 41),
(1582, '2024-05-13 23:14:33', 4, 5, 41),
(1583, '2024-05-13 23:14:33', 8, 9, 41),
(1584, '2024-05-13 23:14:34', 3, 2, 41),
(1585, '2024-05-13 23:14:34', 1, 3, 41),
(1586, '2024-05-13 23:14:35', 7, 5, 41),
(1587, '2024-05-13 23:14:35', 2, 4, 41),
(1588, '2024-05-13 23:14:36', 2, 5, 41),
(1589, '2024-05-13 23:14:36', 5, 3, 41),
(1590, '2024-05-13 23:14:37', 7, 5, 41),
(1591, '2024-05-13 23:14:37', 7, 5, 41),
(1592, '2024-05-13 23:14:37', 1, 3, 41),
(1593, '2024-05-13 23:14:37', 3, 2, 41),
(1594, '2024-05-13 23:14:38', 5, 7, 41),
(1595, '2024-05-13 23:14:38', 2, 4, 41),
(1596, '2024-05-13 23:14:39', 2, 4, 41),
(1597, '2024-05-13 23:14:39', 3, 2, 41),
(1598, '2024-05-13 23:14:40', 4, 5, 41),
(1599, '2024-05-13 23:14:40', 2, 4, 41),
(1600, '2024-05-13 23:14:40', 7, 5, 41),
(1601, '2024-05-13 23:14:40', 5, 7, 41),
(1602, '2024-05-13 23:14:40', 3, 2, 41),
(1603, '2024-05-13 23:14:41', 2, 4, 41),
(1604, '2024-05-13 23:14:43', 5, 7, 41),
(1605, '2024-05-13 23:14:43', 5, 3, 41),
(1606, '2024-05-13 23:14:43', 4, 5, 41),
(1607, '2024-05-13 23:14:43', 1, 2, 41),
(1608, '2024-05-13 23:14:44', 7, 5, 41),
(1609, '2024-05-13 23:14:44', 2, 4, 41),
(1610, '2024-05-13 23:14:46', 7, 5, 41),
(1611, '2024-05-13 23:14:46', 3, 2, 41),
(1612, '2024-05-13 23:14:46', 4, 5, 41),
(1613, '2024-05-13 23:14:46', 1, 2, 41),
(1614, '2024-05-13 23:14:46', 1, 3, 41),
(1615, '2024-05-13 23:14:47', 4, 5, 41),
(1616, '2024-05-13 23:14:47', 5, 6, 41),
(1617, '2024-05-13 23:14:47', 2, 4, 41),
(1618, '2024-05-13 23:14:48', 8, 10, 41),
(1619, '2024-05-13 23:14:48', 4, 5, 41),
(1620, '2024-05-13 23:14:49', 2, 4, 41),
(1621, '2024-05-13 23:14:49', 4, 5, 41),
(1622, '2024-05-13 23:14:49', 1, 3, 41),
(1623, '2024-05-13 23:14:50', 5, 6, 41),
(1624, '2024-05-13 23:14:52', 4, 5, 41),
(1625, '2024-05-13 23:14:52', 1, 3, 41),
(1626, '2024-05-13 23:14:52', 3, 2, 41),
(1627, '2024-05-13 23:14:53', 7, 5, 41),
(1628, '2024-05-13 23:14:53', 5, 3, 41),
(1629, '2024-05-13 23:14:53', 2, 5, 41),
(1630, '2024-05-13 23:14:53', 2, 4, 41),
(1631, '2024-05-13 23:14:54', 5, 6, 41),
(1632, '2024-05-13 23:14:54', 6, 8, 41),
(1633, '2024-05-13 23:14:55', 7, 5, 41),
(1634, '2024-05-13 23:14:55', 4, 5, 41),
(1635, '2024-05-13 23:14:55', 1, 3, 41),
(1636, '2024-05-13 23:14:55', 3, 2, 41),
(1637, '2024-05-13 23:14:56', 2, 4, 41),
(1638, '2024-05-13 23:14:56', 3, 2, 41),
(1639, '2024-05-13 23:14:56', 5, 6, 41),
(1640, '2024-05-13 23:14:56', 5, 7, 41),
(1641, '2024-05-13 23:14:57', 5, 6, 41),
(1642, '2024-05-13 23:14:57', 6, 8, 41),
(1643, '2024-05-13 23:14:57', 8, 9, 41),
(1644, '2024-05-13 23:14:57', 4, 5, 41),
(1645, '2024-05-13 23:14:58', 7, 5, 41),
(1646, '2024-05-13 23:14:58', 5, 6, 41),
(1647, '2024-05-13 23:14:58', 5, 7, 41),
(1648, '2024-05-13 23:14:58', 3, 2, 41),
(1649, '2024-05-13 23:14:59', 5, 3, 41),
(1650, '2024-05-13 23:14:59', 2, 5, 41),
(1651, '2024-05-13 23:15:00', 8, 9, 41),
(1652, '2024-05-13 23:15:00', 5, 7, 41),
(1653, '2024-05-13 23:15:01', 6, 8, 41),
(1654, '2024-05-13 23:15:01', 5, 7, 41),
(1655, '2024-05-13 23:15:01', 4, 5, 41),
(1656, '2024-05-13 23:15:01', 1, 3, 41),
(1657, '2024-05-13 23:15:01', 1, 2, 41),
(1658, '2024-05-13 23:15:02', 3, 2, 41),
(1659, '2024-05-13 23:15:02', 5, 3, 41),
(1660, '2024-05-13 23:15:03', 5, 6, 41),
(1661, '2024-05-13 23:15:03', 6, 8, 41),
(1662, '2024-05-13 23:15:04', 6, 8, 41),
(1663, '2024-05-13 23:15:04', 4, 5, 41),
(1664, '2024-05-13 23:15:04', 3, 2, 41),
(1665, '2024-05-13 23:15:05', 6, 8, 41),
(1666, '2024-05-13 23:15:05', 5, 3, 41),
(1667, '2024-05-13 23:15:05', 3, 2, 41),
(1668, '2024-05-13 23:15:05', 2, 5, 41),
(1669, '2024-05-13 23:15:05', 2, 4, 41),
(1670, '2024-05-13 23:15:06', 8, 9, 41),
(1671, '2024-05-13 23:15:07', 8, 9, 41),
(1672, '2024-05-13 23:15:07', 1, 2, 41),
(1673, '2024-05-13 23:15:07', 1, 3, 41),
(1674, '2024-05-13 23:15:08', 8, 9, 41),
(1675, '2024-05-13 23:15:08', 3, 2, 41),
(1676, '2024-05-13 23:15:08', 5, 7, 41),
(1677, '2024-05-13 23:15:09', 2, 5, 41),
(1678, '2024-05-13 23:15:09', 5, 6, 41),
(1679, '2024-05-13 23:15:10', 6, 8, 41),
(1680, '2024-05-13 23:15:11', 5, 3, 41),
(1681, '2024-05-13 23:15:11', 7, 5, 41),
(1682, '2024-05-13 23:15:11', 2, 5, 41),
(1683, '2024-05-13 23:15:11', 2, 4, 41),
(1684, '2024-05-13 23:15:12', 5, 7, 41),
(1685, '2024-05-13 23:15:12', 2, 4, 41),
(1686, '2024-05-13 23:15:13', 7, 5, 41),
(1687, '2024-05-13 23:15:13', 4, 5, 41),
(1688, '2024-05-13 23:15:13', 1, 2, 41),
(1689, '2024-05-13 23:15:13', 1, 3, 41),
(1690, '2024-05-13 23:15:14', 5, 3, 41),
(1691, '2024-05-13 23:15:14', 3, 2, 41),
(1692, '2024-05-13 23:15:14', 2, 4, 41),
(1693, '2024-05-13 23:15:15', 7, 5, 41),
(1694, '2024-05-13 23:15:16', 7, 5, 41),
(1695, '2024-05-13 23:15:16', 5, 7, 41),
(1696, '2024-05-13 23:15:16', 6, 8, 41),
(1697, '2024-05-13 23:15:16', 1, 3, 41),
(1698, '2024-05-13 23:15:17', 3, 2, 41),
(1699, '2024-05-13 23:15:17', 2, 4, 41),
(1700, '2024-05-13 23:15:18', 2, 5, 41),
(1701, '2024-05-13 23:15:19', 8, 9, 41),
(1702, '2024-05-13 23:15:19', 4, 5, 41),
(1703, '2024-05-13 23:15:19', 3, 2, 41),
(1704, '2024-05-13 23:15:20', 4, 5, 41),
(1705, '2024-05-13 23:15:21', 2, 5, 41),
(1706, '2024-05-13 23:15:21', 5, 3, 41),
(1707, '2024-05-13 23:15:22', 4, 5, 41),
(1708, '2024-05-13 23:15:22', 1, 2, 41),
(1709, '2024-05-13 23:15:22', 1, 3, 41),
(1710, '2024-05-13 23:15:23', 5, 6, 41),
(1711, '2024-05-13 23:15:23', 7, 5, 41),
(1712, '2024-05-13 23:15:24', 3, 2, 41),
(1713, '2024-05-13 23:15:24', 2, 4, 41),
(1714, '2024-05-13 23:15:25', 5, 3, 41),
(1715, '2024-05-13 23:15:25', 4, 5, 41),
(1716, '2024-05-13 23:15:25', 1, 3, 41),
(1717, '2024-05-13 23:15:26', 5, 3, 41),
(1718, '2024-05-13 23:15:26', 2, 5, 41),
(1719, '2024-05-13 23:15:27', 2, 4, 41),
(1720, '2024-05-13 23:15:27', 7, 5, 41),
(1721, '2024-05-13 23:15:28', 5, 6, 41),
(1722, '2024-05-13 23:15:28', 3, 2, 41),
(1723, '2024-05-13 23:15:28', 3, 2, 41),
(1724, '2024-05-13 23:15:29', 3, 2, 41),
(1725, '2024-05-13 23:15:29', 5, 3, 41),
(1726, '2024-05-13 23:15:30', 5, 3, 41),
(1727, '2024-05-13 23:15:30', 6, 8, 41),
(1728, '2024-05-13 23:15:31', 5, 6, 41),
(1729, '2024-05-13 23:15:31', 7, 5, 41),
(1730, '2024-05-13 23:15:31', 1, 2, 41),
(1731, '2024-05-13 23:15:31', 1, 3, 41),
(1732, '2024-05-13 23:15:32', 4, 5, 41),
(1733, '2024-05-13 23:15:32', 3, 2, 41),
(1734, '2024-05-13 23:15:32', 5, 6, 41),
(1735, '2024-05-13 23:15:32', 2, 4, 41),
(1736, '2024-05-13 23:15:32', 2, 5, 41),
(1737, '2024-05-13 23:15:33', 3, 2, 41),
(1738, '2024-05-13 23:15:33', 5, 6, 41),
(1739, '2024-05-13 23:15:34', 1, 3, 41),
(1740, '2024-05-13 23:15:35', 4, 5, 41),
(1741, '2024-05-13 23:15:35', 6, 8, 41),
(1742, '2024-05-13 23:15:35', 5, 3, 41),
(1743, '2024-05-13 23:15:36', 5, 6, 41),
(1744, '2024-05-13 23:15:37', 5, 3, 41),
(1745, '2024-05-13 23:15:37', 2, 5, 41),
(1746, '2024-05-13 23:15:37', 1, 3, 41),
(1747, '2024-05-13 23:15:37', 3, 2, 41),
(1748, '2024-05-13 23:15:38', 6, 8, 41),
(1749, '2024-05-13 23:15:38', 3, 2, 41),
(1750, '2024-05-13 23:15:39', 2, 4, 41),
(1751, '2024-05-13 23:15:39', 6, 8, 41),
(1752, '2024-05-13 23:15:40', 3, 2, 41),
(1753, '2024-05-13 23:15:40', 6, 8, 41),
(1754, '2024-05-13 23:15:40', 4, 5, 41),
(1755, '2024-05-13 23:15:40', 3, 2, 41),
(1756, '2024-05-13 23:15:41', 8, 9, 41),
(1757, '2024-05-13 23:15:41', 5, 6, 41),
(1758, '2024-05-13 23:15:41', 2, 5, 41),
(1759, '2024-05-13 23:15:41', 2, 5, 41),
(1760, '2024-05-13 23:15:42', 5, 6, 41),
(1761, '2024-05-13 23:15:42', 2, 4, 41),
(1762, '2024-05-13 23:15:42', 8, 9, 41),
(1763, '2024-05-13 23:15:43', 2, 4, 41),
(1764, '2024-05-13 23:15:43', 6, 8, 41),
(1765, '2024-05-13 23:15:43', 1, 2, 41),
(1766, '2024-05-13 23:15:44', 5, 7, 41),
(1767, '2024-05-13 23:15:44', 2, 5, 41),
(1768, '2024-05-13 23:15:45', 5, 3, 41),
(1769, '2024-05-13 23:15:45', 8, 10, 41),
(1770, '2024-05-13 23:15:46', 1, 2, 41),
(1771, '2024-05-13 23:15:46', 1, 3, 41),
(1772, '2024-05-13 23:15:47', 5, 3, 41),
(1773, '2024-05-13 23:15:47', 2, 4, 41),
(1774, '2024-05-13 23:15:48', 6, 8, 41),
(1775, '2024-05-13 23:15:49', 6, 8, 41),
(1776, '2024-05-13 23:15:49', 1, 3, 41),
(1777, '2024-05-13 23:15:50', 8, 10, 41),
(1778, '2024-05-13 23:15:50', 3, 2, 41),
(1779, '2024-05-13 23:15:50', 4, 5, 41),
(1780, '2024-05-13 23:15:50', 5, 6, 41),
(1781, '2024-05-13 23:15:51', 4, 5, 41),
(1782, '2024-05-13 23:15:51', 8, 9, 41),
(1783, '2024-05-13 23:15:51', 2, 5, 41),
(1784, '2024-05-13 23:15:51', 5, 3, 41),
(1785, '2024-05-13 23:15:52', 8, 9, 41),
(1786, '2024-05-13 23:15:52', 3, 2, 41),
(1787, '2024-05-13 23:15:52', 1, 3, 41),
(1788, '2024-05-13 23:15:53', 2, 5, 41),
(1789, '2024-05-13 23:15:53', 2, 5, 41),
(1790, '2024-05-13 23:15:53', 2, 4, 41),
(1791, '2024-05-13 23:15:54', 5, 7, 41),
(1792, '2024-05-13 23:15:54', 5, 6, 41),
(1793, '2024-05-13 23:15:54', 3, 2, 41),
(1794, '2024-05-13 23:15:55', 8, 10, 41),
(1795, '2024-05-13 23:15:55', 4, 5, 41),
(1796, '2024-05-13 23:15:55', 3, 2, 41),
(1797, '2024-05-13 23:15:57', 6, 8, 41),
(1798, '2024-05-13 23:15:58', 8, 10, 41),
(1799, '2024-05-13 23:15:58', 5, 7, 41),
(1800, '2024-05-13 23:15:58', 1, 2, 41),
(1801, '2024-05-13 23:15:58', 1, 3, 41),
(1802, '2024-05-13 23:15:59', 7, 5, 41),
(1803, '2024-05-13 23:15:59', 2, 5, 41),
(1804, '2024-05-13 23:16:00', 2, 4, 41),
(1805, '2024-05-13 23:16:00', 5, 6, 41),
(1806, '2024-05-13 23:16:00', 8, 9, 41),
(1807, '2024-05-13 23:16:01', 5, 6, 41),
(1808, '2024-05-13 23:16:01', 6, 8, 41),
(1809, '2024-05-13 23:16:01', 4, 5, 41),
(1810, '2024-05-13 23:16:01', 3, 2, 41),
(1811, '2024-05-13 23:16:01', 1, 3, 41),
(1812, '2024-05-13 23:16:03', 5, 3, 41),
(1813, '2024-05-13 23:16:03', 5, 3, 41),
(1814, '2024-05-13 23:16:04', 2, 4, 41),
(1815, '2024-05-13 23:16:04', 1, 3, 41),
(1816, '2024-05-13 23:16:04', 3, 2, 41),
(1817, '2024-05-13 23:16:05', 2, 5, 41),
(1818, '2024-05-13 23:16:06', 3, 2, 41),
(1819, '2024-05-13 23:16:06', 3, 2, 41),
(1820, '2024-05-13 23:16:07', 6, 8, 41),
(1821, '2024-05-13 23:16:07', 1, 3, 41),
(1822, '2024-05-13 23:16:08', 6, 8, 41),
(1823, '2024-05-13 23:16:08', 4, 5, 41),
(1824, '2024-05-13 23:16:08', 2, 4, 41),
(1825, '2024-05-13 23:16:08', 2, 5, 41),
(1826, '2024-05-13 23:16:09', 5, 6, 41),
(1827, '2024-05-13 23:16:09', 7, 5, 41),
(1828, '2024-05-13 23:16:09', 5, 3, 41),
(1829, '2024-05-13 23:16:10', 8, 9, 41),
(1830, '2024-05-13 23:16:10', 3, 2, 41),
(1831, '2024-05-13 23:16:11', 8, 9, 41),
(1832, '2024-05-13 23:16:11', 5, 6, 41),
(1833, '2024-05-13 23:16:12', 4, 5, 41),
(1834, '2024-05-13 23:16:12', 3, 2, 41),
(1835, '2024-05-13 23:16:13', 7, 5, 41),
(1836, '2024-05-13 23:16:13', 1, 2, 41),
(1837, '2024-05-13 23:16:14', 2, 5, 41),
(1838, '2024-05-13 23:16:14', 2, 4, 41),
(1839, '2024-05-13 23:16:15', 5, 3, 41),
(1840, '2024-05-13 23:16:16', 8, 10, 41),
(1841, '2024-05-13 23:16:16', 4, 5, 41),
(1842, '2024-05-13 23:16:16', 1, 2, 41),
(1843, '2024-05-13 23:16:18', 5, 6, 41),
(1844, '2024-05-13 23:16:18', 6, 8, 41),
(1845, '2024-05-13 23:16:18', 3, 2, 41),
(1846, '2024-05-13 23:16:18', 5, 6, 41),
(1847, '2024-05-13 23:16:19', 2, 5, 41),
(1848, '2024-05-13 23:16:19', 5, 6, 41),
(1849, '2024-05-13 23:16:19', 2, 5, 41),
(1850, '2024-05-13 23:16:19', 5, 7, 41),
(1851, '2024-05-13 23:16:19', 1, 2, 41),
(1852, '2024-05-13 23:16:19', 1, 3, 41),
(1853, '2024-05-13 23:16:21', 8, 9, 41),
(1854, '2024-05-13 23:16:22', 5, 7, 41),
(1855, '2024-05-13 23:16:22', 2, 4, 41),
(1856, '2024-05-13 23:16:22', 4, 5, 41),
(1857, '2024-05-13 23:16:22', 3, 2, 41),
(1858, '2024-05-13 23:16:22', 1, 3, 41),
(1859, '2024-05-13 23:16:23', 2, 5, 41),
(1860, '2024-05-13 23:16:23', 5, 6, 41),
(1861, '2024-05-13 23:16:23', 5, 3, 41),
(1862, '2024-05-13 23:16:25', 6, 8, 41),
(1863, '2024-05-13 23:16:25', 5, 7, 41),
(1864, '2024-05-13 23:16:25', 6, 8, 41),
(1865, '2024-05-13 23:16:25', 3, 2, 41),
(1866, '2024-05-13 23:16:26', 2, 5, 41),
(1867, '2024-05-13 23:16:26', 6, 8, 41),
(1868, '2024-05-13 23:16:26', 3, 2, 41),
(1869, '2024-05-13 23:16:28', 2, 4, 41),
(1870, '2024-05-13 23:16:28', 8, 9, 41),
(1871, '2024-05-13 23:16:28', 8, 9, 41),
(1872, '2024-05-13 23:16:29', 2, 5, 41),
(1873, '2024-05-13 23:16:29', 5, 3, 41),
(1874, '2024-05-13 23:16:30', 4, 5, 41),
(1875, '2024-05-13 23:16:30', 6, 8, 41),
(1876, '2024-05-13 23:16:32', 2, 5, 41),
(1877, '2024-05-13 23:16:32', 2, 4, 41),
(1878, '2024-05-13 23:16:32', 3, 2, 41),
(1879, '2024-05-13 23:16:33', 8, 9, 41),
(1880, '2024-05-13 23:16:34', 7, 5, 41),
(1881, '2024-05-13 23:16:36', 4, 5, 41),
(1882, '2024-05-13 23:16:36', 5, 6, 41),
(1883, '2024-05-13 23:16:36', 2, 4, 41),
(1884, '2024-05-13 23:16:37', 5, 7, 41),
(1885, '2024-05-13 23:16:38', 2, 5, 41),
(1886, '2024-05-13 23:16:39', 5, 3, 41),
(1887, '2024-05-13 23:16:40', 7, 5, 41),
(1888, '2024-05-13 23:16:40', 5, 6, 41),
(1889, '2024-05-13 23:16:40', 4, 5, 41),
(1890, '2024-05-13 23:16:41', 8, 10, 41),
(1891, '2024-05-13 23:16:42', 3, 2, 41),
(1892, '2024-05-13 23:16:42', 5, 6, 41),
(1893, '2024-05-13 23:16:43', 5, 7, 41),
(1894, '2024-05-13 23:16:43', 6, 8, 41),
(1895, '2024-05-13 23:16:44', 4, 5, 41),
(1896, '2024-05-13 23:16:45', 2, 5, 41),
(1897, '2024-05-13 23:16:46', 5, 6, 41),
(1898, '2024-05-13 23:16:46', 8, 9, 41),
(1899, '2024-05-13 23:16:47', 6, 8, 41),
(1900, '2024-05-13 23:16:47', 5, 7, 41),
(1901, '2024-05-13 23:16:49', 6, 8, 41),
(1902, '2024-05-13 23:16:50', 5, 6, 41),
(1903, '2024-05-13 23:16:52', 7, 5, 41),
(1904, '2024-05-13 23:16:52', 2, 4, 41),
(1905, '2024-05-13 23:16:52', 8, 9, 41),
(1906, '2024-05-13 23:16:53', 6, 8, 41),
(1907, '2024-05-13 23:16:55', 5, 6, 41),
(1908, '2024-05-13 23:16:56', 8, 9, 41),
(1909, '2024-05-13 23:16:57', 6, 8, 41),
(1910, '2024-05-13 23:16:58', 7, 5, 41),
(1911, '2024-05-13 23:17:00', 4, 5, 41),
(1912, '2024-05-13 23:17:01', 5, 7, 41),
(1913, '2024-05-13 23:17:02', 5, 6, 41),
(1914, '2024-05-13 23:17:02', 8, 10, 41),
(1915, '2024-05-13 23:17:02', 6, 8, 41),
(1916, '2024-05-13 23:17:02', 7, 5, 41),
(1917, '2024-05-13 23:17:05', 8, 9, 41),
(1918, '2024-05-13 23:17:09', 6, 8, 41),
(1919, '2024-05-13 23:17:10', 5, 3, 41),
(1920, '2024-05-13 23:17:12', 8, 10, 41),
(1921, '2024-05-13 23:17:13', 5, 3, 41),
(1922, '2024-05-13 23:17:14', 3, 2, 41),
(1923, '2024-05-13 23:17:16', 3, 2, 41),
(1924, '2024-05-13 23:17:16', 7, 5, 41),
(1925, '2024-05-13 23:17:24', 2, 4, 41),
(1926, '2024-05-13 23:17:24', 8, 10, 41),
(1927, '2024-05-13 23:17:26', 2, 4, 41),
(1928, '2024-05-13 23:17:26', 5, 6, 41),
(1929, '2024-05-13 23:17:32', 4, 5, 41),
(1930, '2024-05-13 23:17:34', 6, 8, 41),
(1931, '2024-05-13 23:17:37', 8, 9, 41),
(1932, '2024-05-13 23:17:42', 5, 6, 41),
(1933, '2024-05-13 23:17:49', 6, 8, 41),
(1934, '2024-05-13 23:17:52', 8, 9, 41),
(1935, '2000-01-01 00:00:00', 0, 0, NULL),
(1936, '2024-05-13 23:18:08', 1, 2, NULL),
(1937, '2024-05-13 23:18:11', 1, 2, NULL),
(1938, '2024-05-13 23:18:14', 1, 2, NULL),
(1939, '2024-05-13 23:18:17', 1, 2, NULL),
(1940, '2024-05-13 23:18:18', 2, 4, NULL),
(1941, '2024-05-13 23:18:20', 1, 2, NULL),
(1942, '2024-05-13 23:18:23', 1, 2, NULL),
(1943, '2024-05-13 23:18:24', 2, 5, NULL);

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
(1, 24, 0, 1),
(2, 24, 0, 2),
(3, 24, 17, 3),
(4, 24, 2, 4),
(5, 24, 14, 5),
(6, 24, 1, 6),
(7, 24, 1, 7),
(8, 24, 2, 8),
(9, 24, 29, 9),
(10, 24, 14, 10),
(12, 25, 0, 1),
(13, 25, 0, 2),
(14, 25, 17, 3),
(15, 25, 2, 4),
(16, 25, 14, 5),
(17, 25, 1, 6),
(18, 25, 1, 7),
(19, 25, 2, 8),
(20, 25, 29, 9),
(21, 25, 14, 10),
(22, 26, 0, 1),
(23, 26, 0, 2),
(24, 26, 17, 3),
(25, 26, 2, 4),
(26, 26, 14, 5),
(27, 26, 1, 6),
(28, 26, 1, 7),
(29, 26, 2, 8),
(30, 26, 29, 9),
(31, 27, 0, 1),
(32, 27, 0, 2),
(33, 27, 17, 3),
(34, 27, 2, 4),
(35, 27, 14, 5),
(36, 27, 1, 6),
(37, 27, 1, 7),
(38, 27, 2, 8),
(39, 27, 29, 9),
(40, 28, 0, 1),
(41, 28, 0, 2),
(42, 28, 17, 3),
(43, 28, 2, 4),
(44, 28, 14, 5),
(45, 28, 1, 6),
(46, 28, 1, 7),
(47, 28, 2, 8),
(48, 28, 29, 9),
(88, 37, 0, 1),
(89, 37, 0, 2),
(90, 37, 17, 3),
(91, 37, 2, 4),
(92, 37, 14, 5),
(93, 37, 1, 6),
(94, 37, 1, 7),
(95, 37, 2, 8),
(96, 37, 29, 9),
(97, 37, 14, 10),
(98, 38, 0, 1),
(99, 38, 0, 2),
(100, 38, 17, 3),
(101, 38, 2, 4),
(102, 38, 14, 5),
(103, 38, 1, 6),
(104, 38, 1, 7),
(105, 38, 2, 8),
(106, 38, 29, 9),
(107, 38, 14, 10),
(108, 39, 0, 1),
(109, 39, 0, 2),
(110, 39, 17, 3),
(111, 39, 2, 4),
(112, 39, 14, 5),
(113, 39, 1, 6),
(114, 39, 1, 7),
(115, 39, 2, 8),
(116, 39, 29, 9),
(117, 39, 14, 10),
(118, 40, 0, 1),
(119, 40, 0, 2),
(120, 40, 17, 3),
(121, 40, 2, 4),
(122, 40, 14, 5),
(123, 40, 1, 6),
(124, 40, 1, 7),
(125, 40, 2, 8),
(126, 40, 29, 9),
(127, 40, 14, 10),
(128, 41, 0, 1),
(129, 41, 0, 2),
(130, 41, 17, 3),
(131, 41, 2, 4),
(132, 41, 14, 5),
(133, 41, 1, 6),
(134, 41, 1, 7),
(135, 41, 2, 8),
(136, 41, 29, 9),
(137, 41, 14, 10);

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
        IF NEW.NúmeroRatosFinal = limiteRatos AND NEW.Sala <> 1 THEN
            CAll InserirAlerta(NEW.Sala,NULL,NULL, 'Capacidade da sala', 'Limite de ratos atingido!');
        ELSEIF NEW.NúmeroRatosFinal > limiteRatos AND NEW.Sala <> 1  THEN
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
) ENGINE=InnoDB AUTO_INCREMENT=1489 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `medicoestemperatura`
--

INSERT INTO `medicoestemperatura` (`IDMedição`, `DataHora`, `Leitura`, `Sensor`, `IDExperiencia`) VALUES
(1, '2024-05-13 22:59:21', '17.00', 3, NULL),
(2, '2024-05-13 22:59:21', '16.00', 2, NULL),
(3, '2024-05-13 22:59:22', '18.00', 3, NULL),
(4, '2024-05-13 22:59:22', '17.00', 2, NULL),
(5, '2024-05-13 22:59:23', '19.00', 3, NULL),
(6, '2024-05-13 22:59:23', '18.00', 2, NULL),
(7, '2024-05-13 22:59:24', '20.00', 3, NULL),
(8, '2024-05-13 22:59:24', '19.00', 2, NULL),
(9, '2024-05-13 22:59:25', '21.00', 3, NULL),
(10, '2024-05-13 22:59:25', '20.00', 2, NULL),
(11, '2024-05-13 22:59:26', '22.00', 3, NULL),
(12, '2024-05-13 22:59:26', '21.00', 2, NULL),
(13, '2024-05-13 22:59:27', '23.00', 3, NULL),
(14, '2024-05-13 22:59:27', '22.00', 2, NULL),
(15, '2024-05-13 22:59:28', '24.00', 3, NULL),
(16, '2024-05-13 22:59:28', '23.00', 2, NULL),
(17, '2024-05-13 22:59:29', '25.00', 3, NULL),
(18, '2024-05-13 22:59:29', '24.00', 2, NULL),
(19, '2024-05-13 22:59:30', '26.00', 3, NULL),
(20, '2024-05-13 22:59:30', '25.00', 2, NULL),
(21, '2024-05-13 22:59:31', '27.00', 3, NULL),
(22, '2024-05-13 22:59:31', '26.00', 2, NULL),
(23, '2024-05-13 22:59:32', '28.00', 3, NULL),
(24, '2024-05-13 22:59:32', '27.00', 2, NULL),
(25, '2024-05-13 22:59:33', '29.00', 3, NULL),
(26, '2024-05-13 22:59:33', '28.00', 2, NULL),
(27, '2024-05-13 22:59:34', '30.00', 3, NULL),
(28, '2024-05-13 22:59:34', '29.00', 2, NULL),
(29, '2024-05-13 22:59:35', '31.00', 3, NULL),
(30, '2024-05-13 22:59:35', '30.00', 2, NULL),
(31, '2024-05-13 22:59:36', '32.00', 3, NULL),
(32, '2024-05-13 22:59:36', '31.00', 2, NULL),
(33, '2024-05-13 22:59:37', '32.00', 2, NULL),
(34, '2024-05-13 22:59:37', '33.00', 3, NULL),
(35, '2024-05-13 22:59:38', '33.00', 2, NULL),
(36, '2024-05-13 22:59:38', '34.00', 3, NULL),
(37, '2024-05-13 22:59:39', '35.00', 3, NULL),
(38, '2024-05-13 22:59:39', '34.00', 2, NULL),
(39, '2024-05-13 22:59:40', '35.00', 2, NULL),
(40, '2024-05-13 22:59:40', '36.00', 3, NULL),
(41, '2024-05-13 22:59:41', '36.00', 2, NULL),
(42, '2024-05-13 22:59:41', '37.00', 3, NULL),
(43, '2024-05-13 22:59:42', '38.00', 3, NULL),
(44, '2024-05-13 22:59:42', '37.00', 2, NULL),
(45, '2024-05-13 22:59:43', '38.00', 2, NULL),
(46, '2024-05-13 22:59:43', '39.00', 3, NULL),
(47, '2024-05-13 22:59:44', '40.00', 3, NULL),
(48, '2024-05-13 22:59:44', '39.00', 2, NULL),
(49, '2024-05-13 22:59:45', '41.00', 3, NULL),
(50, '2024-05-13 22:59:45', '40.00', 2, NULL),
(51, '2024-05-13 22:59:46', '41.00', 2, NULL),
(52, '2024-05-13 22:59:46', '42.00', 3, NULL),
(53, '2024-05-13 22:59:47', '42.00', 2, NULL),
(54, '2024-05-13 22:59:47', '43.00', 3, NULL),
(55, '2024-05-13 22:59:48', '44.00', 3, NULL),
(56, '2024-05-13 22:59:48', '43.00', 2, NULL),
(57, '2024-05-13 22:59:49', '44.00', 2, NULL),
(58, '2024-05-13 22:59:49', '45.00', 3, NULL),
(59, '2024-05-13 22:59:50', '46.00', 3, NULL),
(60, '2024-05-13 22:59:50', '45.00', 2, NULL),
(61, '2024-05-13 22:59:51', '46.00', 2, NULL),
(62, '2024-05-13 22:59:51', '47.00', 3, NULL),
(63, '2024-05-13 22:59:52', '47.00', 2, NULL),
(64, '2024-05-13 22:59:52', '48.00', 3, NULL),
(65, '2024-05-13 22:59:53', '49.00', 3, NULL),
(66, '2024-05-13 22:59:53', '48.00', 2, NULL),
(67, '2024-05-13 22:59:54', '49.00', 2, NULL),
(68, '2024-05-13 22:59:54', '50.00', 3, NULL),
(69, '2024-05-13 22:59:55', '50.00', 2, NULL),
(70, '2024-05-13 22:59:55', '51.00', 3, NULL),
(71, '2024-05-13 22:59:56', '50.00', 3, NULL),
(72, '2024-05-13 22:59:56', '49.00', 2, NULL),
(73, '2024-05-13 22:59:57', '48.00', 2, NULL),
(74, '2024-05-13 22:59:57', '49.00', 3, NULL),
(75, '2024-05-13 22:59:58', '47.00', 2, NULL),
(76, '2024-05-13 22:59:58', '48.00', 3, NULL),
(77, '2024-05-13 22:59:59', '46.00', 2, NULL),
(78, '2024-05-13 22:59:59', '47.00', 3, NULL),
(79, '2024-05-13 23:00:00', '45.00', 2, NULL),
(80, '2024-05-13 23:00:00', '46.00', 3, NULL),
(81, '2024-05-13 23:00:01', '45.00', 3, NULL),
(82, '2024-05-13 23:00:01', '44.00', 2, NULL),
(83, '2024-05-13 23:00:02', '43.00', 2, NULL),
(84, '2024-05-13 23:00:02', '44.00', 3, NULL),
(85, '2024-05-13 23:00:03', '42.00', 2, NULL),
(86, '2024-05-13 23:00:03', '43.00', 3, NULL),
(87, '2024-05-13 23:00:04', '41.00', 2, NULL),
(88, '2024-05-13 23:00:04', '42.00', 3, NULL),
(89, '2024-05-13 23:00:05', '40.00', 2, NULL),
(90, '2024-05-13 23:00:05', '41.00', 3, NULL),
(91, '2024-05-13 23:00:06', '39.00', 2, NULL),
(92, '2024-05-13 23:00:06', '40.00', 3, NULL),
(93, '2024-05-13 23:00:07', '38.00', 2, NULL),
(94, '2024-05-13 23:00:07', '39.00', 3, NULL),
(95, '2024-05-13 23:00:08', '37.00', 2, NULL),
(96, '2024-05-13 23:00:08', '38.00', 3, NULL),
(97, '2024-05-13 23:00:09', '36.00', 2, NULL),
(98, '2024-05-13 23:00:09', '37.00', 3, NULL),
(99, '2024-05-13 23:00:10', '36.00', 3, NULL),
(100, '2024-05-13 23:00:10', '35.00', 2, NULL),
(101, '2024-05-13 23:00:11', '34.00', 2, NULL),
(102, '2024-05-13 23:00:11', '35.00', 3, NULL),
(103, '2024-05-13 23:00:12', '34.00', 3, NULL),
(104, '2024-05-13 23:00:12', '33.00', 2, NULL),
(105, '2024-05-13 23:00:13', '32.00', 2, NULL),
(106, '2024-05-13 23:00:13', '33.00', 3, NULL),
(107, '2024-05-13 23:00:14', '32.00', 3, NULL),
(108, '2024-05-13 23:00:14', '31.00', 2, NULL),
(109, '2024-05-13 23:00:15', '31.00', 3, NULL),
(110, '2024-05-13 23:00:15', '30.00', 2, NULL),
(111, '2024-05-13 23:00:16', '30.00', 3, NULL),
(112, '2024-05-13 23:00:16', '29.00', 2, NULL),
(113, '2024-05-13 23:00:17', '29.00', 3, NULL),
(114, '2024-05-13 23:00:17', '28.00', 2, NULL),
(115, '2024-05-13 23:00:18', '27.00', 2, NULL),
(116, '2024-05-13 23:00:18', '28.00', 3, NULL),
(117, '2024-05-13 23:00:19', '26.00', 2, NULL),
(118, '2024-05-13 23:00:19', '27.00', 3, NULL),
(119, '2024-05-13 23:00:20', '25.00', 2, NULL),
(120, '2024-05-13 23:00:20', '26.00', 3, NULL),
(121, '2024-05-13 23:00:21', '25.00', 3, NULL),
(122, '2024-05-13 23:00:21', '24.00', 2, NULL),
(123, '2024-05-13 23:00:22', '24.00', 3, NULL),
(124, '2024-05-13 23:00:22', '23.00', 2, NULL),
(125, '2024-05-13 23:00:23', '23.00', 3, NULL),
(126, '2024-05-13 23:00:23', '22.00', 2, NULL),
(127, '2024-05-13 23:00:24', '22.00', 3, NULL),
(128, '2024-05-13 23:00:24', '21.00', 2, NULL),
(129, '2024-05-13 23:00:25', '21.00', 3, NULL),
(130, '2024-05-13 23:00:25', '20.00', 2, NULL),
(131, '2024-05-13 23:00:26', '20.00', 3, NULL),
(132, '2024-05-13 23:00:26', '19.00', 2, NULL),
(133, '2024-05-13 23:00:27', '19.00', 3, NULL),
(134, '2024-05-13 23:00:27', '18.00', 2, NULL),
(135, '2024-05-13 23:00:28', '18.00', 3, NULL),
(136, '2024-05-13 23:00:28', '17.00', 2, NULL),
(137, '2024-05-13 23:00:29', '17.00', 3, NULL),
(138, '2024-05-13 23:00:29', '16.00', 2, NULL),
(139, '2024-05-13 23:00:30', '16.00', 3, NULL),
(140, '2024-05-13 23:00:30', '15.00', 2, NULL),
(141, '2024-05-13 23:00:31', '15.00', 3, NULL),
(142, '2024-05-13 23:00:31', '14.00', 2, NULL),
(143, '2024-05-13 23:00:32', '14.00', 3, NULL),
(144, '2024-05-13 23:00:32', '13.00', 2, NULL),
(145, '2024-05-13 23:00:33', '13.00', 3, NULL),
(146, '2024-05-13 23:00:33', '12.00', 2, NULL),
(147, '2024-05-13 23:00:34', '12.00', 3, NULL),
(148, '2024-05-13 23:00:34', '11.00', 2, NULL),
(149, '2024-05-13 23:00:35', '11.00', 3, NULL),
(150, '2024-05-13 23:00:35', '10.00', 2, NULL),
(151, '2024-05-13 23:00:36', '10.00', 3, NULL),
(152, '2024-05-13 23:00:36', '9.00', 2, NULL),
(153, '2024-05-13 23:00:37', '9.00', 3, NULL),
(154, '2024-05-13 23:00:37', '8.00', 2, NULL),
(155, '2024-05-13 23:00:38', '8.00', 3, NULL),
(156, '2024-05-13 23:00:38', '7.00', 2, NULL),
(157, '2024-05-13 23:00:39', '7.00', 3, NULL),
(158, '2024-05-13 23:00:39', '6.00', 2, NULL),
(159, '2024-05-13 23:00:40', '5.00', 2, NULL),
(160, '2024-05-13 23:00:40', '6.00', 3, NULL),
(161, '2024-05-13 23:00:41', '4.00', 2, NULL),
(162, '2024-05-13 23:00:41', '5.00', 3, NULL),
(163, '2024-05-13 23:00:42', '3.00', 2, NULL),
(164, '2024-05-13 23:00:42', '4.00', 3, NULL),
(165, '2024-05-13 23:00:43', '2.00', 2, NULL),
(166, '2024-05-13 23:00:43', '3.00', 3, NULL),
(167, '2024-05-13 23:00:44', '2.00', 3, NULL),
(168, '2024-05-13 23:00:44', '1.00', 2, NULL),
(169, '2024-05-13 23:00:45', '1.00', 3, NULL),
(170, '2024-05-13 23:00:45', '0.00', 2, NULL),
(171, '2024-05-13 23:00:47', '2.00', 3, NULL),
(172, '2024-05-13 23:00:47', '1.00', 2, NULL),
(173, '2024-05-13 23:00:48', '3.00', 3, NULL),
(174, '2024-05-13 23:00:48', '2.00', 2, NULL),
(175, '2024-05-13 23:00:49', '4.00', 3, NULL),
(176, '2024-05-13 23:00:49', '3.00', 2, NULL),
(177, '2024-05-13 23:00:50', '4.00', 2, NULL),
(178, '2024-05-13 23:00:52', '5.00', 2, NULL),
(179, '2024-05-13 23:00:54', '6.00', 2, NULL),
(180, '2024-05-13 23:00:56', '7.00', 2, NULL),
(181, '2024-05-13 23:00:58', '8.00', 2, NULL),
(182, '2024-05-13 23:00:50', '5.00', 3, NULL),
(183, '2024-05-13 23:00:52', '6.00', 3, NULL),
(184, '2024-05-13 23:00:54', '7.00', 3, NULL),
(185, '2024-05-13 23:01:00', '9.00', 2, NULL),
(186, '2024-05-13 23:00:56', '8.00', 3, NULL),
(187, '2024-05-13 23:00:58', '9.00', 3, NULL),
(188, '2024-05-13 23:01:00', '10.00', 3, NULL),
(189, '2024-05-13 23:01:01', '10.00', 2, NULL),
(190, '2024-05-13 23:01:01', '11.00', 3, NULL),
(191, '2024-05-13 23:01:02', '11.00', 2, NULL),
(192, '2024-05-13 23:01:02', '12.00', 3, NULL),
(193, '2024-05-13 23:01:03', '12.00', 2, NULL),
(194, '2024-05-13 23:01:03', '13.00', 3, NULL),
(195, '2024-05-13 23:01:04', '14.00', 3, NULL),
(196, '2024-05-13 23:01:04', '13.00', 2, NULL),
(197, '2024-05-13 23:01:05', '14.00', 2, NULL),
(198, '2024-05-13 23:01:05', '15.00', 3, NULL),
(199, '2024-05-13 23:01:06', '15.00', 2, NULL),
(200, '2024-05-13 23:01:06', '16.00', 3, NULL),
(201, '2024-05-13 23:01:07', '16.00', 2, NULL),
(202, '2024-05-13 23:01:07', '17.00', 3, NULL),
(203, '2024-05-13 23:01:08', '17.00', 2, NULL),
(204, '2024-05-13 23:01:08', '18.00', 3, NULL),
(205, '2024-05-13 23:01:09', '18.00', 2, NULL),
(206, '2024-05-13 23:01:09', '19.00', 3, NULL),
(207, '2024-05-13 23:01:10', '20.00', 3, NULL),
(208, '2024-05-13 23:01:10', '19.00', 2, NULL),
(209, '2024-05-13 23:01:11', '21.00', 3, NULL),
(210, '2024-05-13 23:01:11', '20.00', 2, NULL),
(211, '2024-05-13 23:01:12', '21.00', 2, NULL),
(212, '2024-05-13 23:01:12', '22.00', 3, NULL),
(213, '2024-05-13 23:01:13', '23.00', 3, NULL),
(214, '2024-05-13 23:01:13', '22.00', 2, NULL),
(215, '2024-05-13 23:01:14', '23.00', 2, NULL),
(216, '2024-05-13 23:01:14', '24.00', 3, NULL),
(217, '2024-05-13 23:01:15', '25.00', 3, NULL),
(218, '2024-05-13 23:01:15', '24.00', 2, NULL),
(219, '2024-05-13 23:01:16', '26.00', 3, NULL),
(220, '2024-05-13 23:01:16', '25.00', 2, NULL),
(221, '2024-05-13 23:01:17', '27.00', 3, NULL),
(222, '2024-05-13 23:01:17', '26.00', 2, NULL),
(223, '2024-05-13 23:01:18', '28.00', 3, NULL),
(224, '2024-05-13 23:01:18', '27.00', 2, NULL),
(225, '2024-05-13 23:01:19', '29.00', 3, NULL),
(226, '2024-05-13 23:01:19', '28.00', 2, NULL),
(227, '2024-05-13 23:01:20', '30.00', 3, NULL),
(228, '2024-05-13 23:01:20', '29.00', 2, NULL),
(229, '2024-05-13 23:01:21', '31.00', 3, NULL),
(230, '2024-05-13 23:01:21', '30.00', 2, NULL),
(231, '2024-05-13 23:01:22', '31.00', 2, NULL),
(232, '2024-05-13 23:01:22', '32.00', 3, NULL),
(233, '2024-05-13 23:01:23', '33.00', 3, NULL),
(234, '2024-05-13 23:01:23', '32.00', 2, NULL),
(235, '2024-05-13 23:01:24', '33.00', 2, NULL),
(236, '2024-05-13 23:01:24', '34.00', 3, NULL),
(237, '2024-05-13 23:01:25', '35.00', 3, NULL),
(238, '2024-05-13 23:01:25', '34.00', 2, NULL),
(239, '2024-05-13 23:01:26', '36.00', 3, NULL),
(240, '2024-05-13 23:01:26', '35.00', 2, NULL),
(241, '2024-05-13 23:01:27', '36.00', 2, NULL),
(242, '2024-05-13 23:01:27', '37.00', 3, NULL),
(243, '2024-05-13 23:01:28', '38.00', 3, NULL),
(244, '2024-05-13 23:01:28', '37.00', 2, NULL),
(245, '2024-05-13 23:01:29', '39.00', 3, NULL),
(246, '2024-05-13 23:01:29', '38.00', 2, NULL),
(247, '2024-05-13 23:01:30', '40.00', 3, NULL),
(248, '2024-05-13 23:01:30', '39.00', 2, NULL),
(249, '2024-05-13 23:01:31', '41.00', 3, NULL),
(250, '2024-05-13 23:01:31', '40.00', 2, NULL),
(251, '2024-05-13 23:01:32', '42.00', 3, NULL),
(252, '2024-05-13 23:01:32', '41.00', 2, NULL),
(253, '2024-05-13 23:01:33', '43.00', 3, NULL),
(254, '2024-05-13 23:01:33', '42.00', 2, NULL),
(255, '2024-05-13 23:01:34', '44.00', 3, NULL),
(256, '2024-05-13 23:01:34', '43.00', 2, NULL),
(257, '2024-05-13 23:01:35', '45.00', 3, NULL),
(258, '2024-05-13 23:01:35', '44.00', 2, NULL),
(259, '2024-05-13 23:01:36', '46.00', 3, NULL),
(260, '2024-05-13 23:01:36', '45.00', 2, NULL),
(261, '2024-05-13 23:01:37', '47.00', 3, NULL),
(262, '2024-05-13 23:01:37', '46.00', 2, NULL),
(263, '2024-05-13 23:01:38', '48.00', 3, NULL),
(264, '2024-05-13 23:01:38', '47.00', 2, NULL),
(265, '2024-05-13 23:01:39', '49.00', 3, NULL),
(266, '2024-05-13 23:01:39', '48.00', 2, NULL),
(267, '2024-05-13 23:01:40', '50.00', 3, NULL),
(268, '2024-05-13 23:01:40', '49.00', 2, NULL),
(269, '2024-05-13 23:01:41', '51.00', 3, NULL),
(270, '2024-05-13 23:01:41', '50.00', 2, NULL),
(271, '2024-05-13 23:01:42', '50.00', 3, NULL),
(272, '2024-05-13 23:01:42', '49.00', 2, NULL),
(273, '2024-05-13 23:01:43', '49.00', 3, NULL),
(274, '2024-05-13 23:01:43', '48.00', 2, NULL),
(275, '2024-05-13 23:01:44', '48.00', 3, NULL),
(276, '2024-05-13 23:01:44', '47.00', 2, NULL),
(277, '2024-05-13 23:01:45', '47.00', 3, NULL),
(278, '2024-05-13 23:01:45', '46.00', 2, NULL),
(279, '2024-05-13 23:01:46', '46.00', 3, NULL),
(280, '2024-05-13 23:01:46', '45.00', 2, NULL),
(281, '2024-05-13 23:01:47', '45.00', 3, NULL),
(282, '2024-05-13 23:01:47', '44.00', 2, NULL),
(283, '2024-05-13 23:01:48', '44.00', 3, NULL),
(284, '2024-05-13 23:01:48', '43.00', 2, NULL),
(285, '2024-05-13 23:01:49', '43.00', 3, NULL),
(286, '2024-05-13 23:01:49', '42.00', 2, NULL),
(287, '2024-05-13 23:01:50', '42.00', 3, NULL),
(288, '2024-05-13 23:01:50', '41.00', 2, NULL),
(289, '2024-05-13 23:01:51', '41.00', 3, NULL),
(290, '2024-05-13 23:01:51', '40.00', 2, NULL),
(291, '2024-05-13 23:01:52', '40.00', 3, NULL),
(292, '2024-05-13 23:01:52', '39.00', 2, NULL),
(293, '2024-05-13 23:01:53', '39.00', 3, NULL),
(294, '2024-05-13 23:01:53', '38.00', 2, NULL),
(295, '2024-05-13 23:01:54', '38.00', 3, NULL),
(296, '2024-05-13 23:01:54', '37.00', 2, NULL),
(297, '2024-05-13 23:01:55', '37.00', 3, NULL),
(298, '2024-05-13 23:01:55', '36.00', 2, NULL),
(299, '2024-05-13 23:01:56', '36.00', 3, NULL),
(300, '2024-05-13 23:01:56', '35.00', 2, NULL),
(301, '2024-05-13 23:01:57', '35.00', 3, NULL),
(302, '2024-05-13 23:01:57', '34.00', 2, NULL),
(303, '2024-05-13 23:01:58', '34.00', 3, NULL),
(304, '2024-05-13 23:01:58', '33.00', 2, NULL),
(305, '2024-05-13 23:01:59', '33.00', 3, NULL),
(306, '2024-05-13 23:01:59', '32.00', 2, NULL),
(307, '2024-05-13 23:02:00', '32.00', 3, NULL),
(308, '2024-05-13 23:02:00', '31.00', 2, NULL),
(309, '2024-05-13 23:02:01', '31.00', 3, NULL),
(310, '2024-05-13 23:02:01', '30.00', 2, NULL),
(311, '2024-05-13 23:02:02', '30.00', 3, NULL),
(312, '2024-05-13 23:02:02', '29.00', 2, NULL),
(313, '2024-05-13 23:02:03', '29.00', 3, NULL),
(314, '2024-05-13 23:02:03', '28.00', 2, NULL),
(315, '2024-05-13 23:02:04', '28.00', 3, NULL),
(316, '2024-05-13 23:02:04', '27.00', 2, NULL),
(317, '2024-05-13 23:02:05', '27.00', 3, NULL),
(318, '2024-05-13 23:02:05', '26.00', 2, NULL),
(319, '2024-05-13 23:02:06', '26.00', 3, NULL),
(320, '2024-05-13 23:02:06', '25.00', 2, NULL),
(321, '2024-05-13 23:02:07', '25.00', 3, NULL),
(322, '2024-05-13 23:02:07', '24.00', 2, NULL),
(323, '2024-05-13 23:02:08', '24.00', 3, NULL),
(324, '2024-05-13 23:02:08', '23.00', 2, NULL),
(325, '2024-05-13 23:02:09', '22.00', 2, NULL),
(326, '2024-05-13 23:02:09', '23.00', 3, NULL),
(327, '2024-05-13 23:02:10', '21.00', 2, NULL),
(328, '2024-05-13 23:02:10', '22.00', 3, NULL),
(329, '2024-05-13 23:02:11', '20.00', 2, NULL),
(330, '2024-05-13 23:02:11', '21.00', 3, NULL),
(331, '2024-05-13 23:02:12', '19.00', 2, NULL),
(332, '2024-05-13 23:02:12', '20.00', 3, NULL),
(333, '2024-05-13 23:02:13', '19.00', 3, NULL),
(334, '2024-05-13 23:02:13', '18.00', 2, NULL),
(335, '2024-05-13 23:02:14', '17.00', 2, NULL),
(336, '2024-05-13 23:02:14', '18.00', 3, NULL),
(337, '2024-05-13 23:02:15', '17.00', 3, NULL),
(338, '2024-05-13 23:02:15', '16.00', 2, NULL),
(339, '2024-05-13 23:02:16', '15.00', 2, NULL),
(340, '2024-05-13 23:02:16', '16.00', 3, NULL),
(341, '2024-05-13 23:02:17', '14.00', 2, NULL),
(342, '2024-05-13 23:02:17', '15.00', 3, NULL),
(343, '2024-05-13 23:02:18', '13.00', 2, NULL),
(344, '2024-05-13 23:02:18', '14.00', 3, NULL),
(345, '2024-05-13 23:02:19', '12.00', 2, NULL),
(346, '2024-05-13 23:02:19', '13.00', 3, NULL),
(347, '2024-05-13 23:02:20', '11.00', 2, NULL),
(348, '2024-05-13 23:02:20', '12.00', 3, NULL),
(349, '2024-05-13 23:02:21', '10.00', 2, NULL),
(350, '2024-05-13 23:02:21', '11.00', 3, NULL),
(351, '2024-05-13 23:02:22', '9.00', 2, NULL),
(352, '2024-05-13 23:02:22', '10.00', 3, NULL),
(353, '2024-05-13 23:02:23', '8.00', 2, NULL),
(354, '2024-05-13 23:02:23', '9.00', 3, NULL),
(355, '2024-05-13 23:02:24', '8.00', 3, NULL),
(356, '2024-05-13 23:02:24', '7.00', 2, NULL),
(357, '2024-05-13 23:02:26', '7.00', 3, NULL),
(358, '2024-05-13 23:02:25', '6.00', 2, NULL),
(359, '2024-05-13 23:02:27', '6.00', 3, NULL),
(360, '2024-05-13 23:02:27', '5.00', 2, NULL),
(361, '2024-05-13 23:02:28', '5.00', 3, NULL),
(362, '2024-05-13 23:02:28', '4.00', 2, NULL),
(363, '2024-05-13 23:02:29', '4.00', 3, NULL),
(364, '2024-05-13 23:02:29', '3.00', 2, NULL),
(365, '2024-05-13 23:02:30', '3.00', 3, NULL),
(366, '2024-05-13 23:02:30', '2.00', 2, NULL),
(367, '2024-05-13 23:02:31', '2.00', 3, NULL),
(368, '2024-05-13 23:02:31', '1.00', 2, NULL),
(369, '2024-05-13 23:02:32', '1.00', 3, NULL),
(370, '2024-05-13 23:02:32', '0.00', 2, NULL),
(371, '2024-05-13 23:02:33', '2.00', 3, NULL),
(372, '2024-05-13 23:02:33', '1.00', 2, NULL),
(373, '2024-05-13 23:02:34', '3.00', 3, NULL),
(374, '2024-05-13 23:02:34', '2.00', 2, NULL),
(375, '2024-05-13 23:02:35', '4.00', 3, NULL),
(376, '2024-05-13 23:02:35', '3.00', 2, NULL),
(377, '2024-05-13 23:02:36', '5.00', 3, NULL),
(378, '2024-05-13 23:02:36', '4.00', 2, NULL),
(379, '2024-05-13 23:02:37', '6.00', 3, NULL),
(380, '2024-05-13 23:02:37', '5.00', 2, NULL),
(381, '2024-05-13 23:02:38', '7.00', 3, NULL),
(382, '2024-05-13 23:02:38', '6.00', 2, NULL),
(383, '2024-05-13 23:02:39', '8.00', 3, NULL),
(384, '2024-05-13 23:02:39', '7.00', 2, NULL),
(385, '2024-05-13 23:02:40', '9.00', 3, NULL),
(386, '2024-05-13 23:02:40', '8.00', 2, NULL),
(387, '2024-05-13 23:02:41', '10.00', 3, NULL),
(388, '2024-05-13 23:02:41', '9.00', 2, NULL),
(389, '2024-05-13 23:02:42', '10.00', 2, NULL),
(390, '2024-05-13 23:02:42', '11.00', 3, NULL),
(391, '2024-05-13 23:02:43', '11.00', 2, NULL),
(392, '2024-05-13 23:02:43', '12.00', 3, NULL),
(393, '2024-05-13 23:02:44', '12.00', 2, NULL),
(394, '2024-05-13 23:02:46', '13.00', 2, NULL),
(395, '2024-05-13 23:02:44', '13.00', 3, NULL),
(396, '2024-05-13 23:02:46', '14.00', 3, NULL),
(397, '2024-05-13 23:02:47', '15.00', 3, NULL),
(398, '2024-05-13 23:02:47', '14.00', 2, NULL),
(399, '2024-05-13 23:02:48', '15.00', 2, NULL),
(400, '2024-05-13 23:02:48', '16.00', 3, NULL),
(401, '2024-05-13 23:02:49', '16.00', 2, NULL),
(402, '2024-05-13 23:02:49', '17.00', 3, NULL),
(403, '2024-05-13 23:02:50', '17.00', 2, NULL),
(404, '2024-05-13 23:02:50', '18.00', 3, NULL),
(405, '2024-05-13 23:02:51', '18.00', 2, NULL),
(406, '2024-05-13 23:02:51', '19.00', 3, NULL),
(407, '2024-05-13 23:02:52', '19.00', 2, NULL),
(408, '2024-05-13 23:02:52', '20.00', 3, NULL),
(409, '2024-05-13 23:02:53', '20.00', 2, NULL),
(410, '2024-05-13 23:02:53', '21.00', 3, NULL),
(411, '2024-05-13 23:02:54', '22.00', 3, NULL),
(412, '2024-05-13 23:02:54', '21.00', 2, NULL),
(413, '2024-05-13 23:02:55', '22.00', 2, NULL),
(414, '2024-05-13 23:02:55', '23.00', 3, NULL),
(415, '2024-05-13 23:02:56', '23.00', 2, NULL),
(416, '2024-05-13 23:02:56', '24.00', 3, NULL),
(417, '2024-05-13 23:02:57', '24.00', 2, NULL),
(418, '2024-05-13 23:02:57', '25.00', 3, NULL),
(419, '2024-05-13 23:02:58', '26.00', 3, NULL),
(420, '2024-05-13 23:02:58', '25.00', 2, NULL),
(421, '2024-05-13 23:02:59', '27.00', 3, NULL),
(422, '2024-05-13 23:02:59', '26.00', 2, NULL),
(423, '2024-05-13 23:03:00', '28.00', 3, NULL),
(424, '2024-05-13 23:03:00', '27.00', 2, NULL),
(425, '2024-05-13 23:03:01', '28.00', 2, NULL),
(426, '2024-05-13 23:03:01', '29.00', 3, NULL),
(427, '2024-05-13 23:03:02', '29.00', 2, NULL),
(428, '2024-05-13 23:03:02', '30.00', 3, NULL),
(429, '2024-05-13 23:03:03', '31.00', 3, NULL),
(430, '2024-05-13 23:03:03', '30.00', 2, NULL),
(431, '2024-05-13 23:03:04', '32.00', 3, NULL),
(432, '2024-05-13 23:03:04', '31.00', 2, NULL),
(433, '2024-05-13 23:03:05', '33.00', 3, NULL),
(434, '2024-05-13 23:03:05', '32.00', 2, NULL),
(435, '2024-05-13 23:03:06', '34.00', 3, NULL),
(436, '2024-05-13 23:03:06', '33.00', 2, NULL),
(437, '2024-05-13 23:03:07', '35.00', 3, NULL),
(438, '2024-05-13 23:03:07', '34.00', 2, NULL),
(439, '2024-05-13 23:03:08', '36.00', 3, NULL),
(440, '2024-05-13 23:03:08', '35.00', 2, NULL),
(441, '2024-05-13 23:03:09', '36.00', 2, NULL),
(442, '2024-05-13 23:03:09', '37.00', 3, NULL),
(443, '2024-05-13 23:03:10', '37.00', 2, NULL),
(444, '2024-05-13 23:03:10', '38.00', 3, NULL),
(445, '2024-05-13 23:03:11', '38.00', 2, NULL),
(446, '2024-05-13 23:03:11', '39.00', 3, NULL),
(447, '2024-05-13 23:03:12', '39.00', 2, NULL),
(448, '2024-05-13 23:03:12', '40.00', 3, NULL),
(449, '2024-05-13 23:03:13', '40.00', 2, NULL),
(450, '2024-05-13 23:03:13', '41.00', 3, NULL),
(451, '2024-05-13 23:03:14', '42.00', 3, NULL),
(452, '2024-05-13 23:03:14', '41.00', 2, NULL),
(453, '2024-05-13 23:03:15', '43.00', 3, NULL),
(454, '2024-05-13 23:03:15', '42.00', 2, NULL),
(455, '2024-05-13 23:03:16', '43.00', 2, NULL),
(456, '2024-05-13 23:03:16', '44.00', 3, NULL),
(457, '2024-05-13 23:03:17', '44.00', 2, NULL),
(458, '2024-05-13 23:03:17', '45.00', 3, NULL),
(459, '2024-05-13 23:03:18', '46.00', 3, NULL),
(460, '2024-05-13 23:03:18', '45.00', 2, NULL),
(461, '2024-05-13 23:03:19', '47.00', 3, NULL),
(462, '2024-05-13 23:03:19', '46.00', 2, NULL),
(463, '2024-05-13 23:03:20', '48.00', 3, NULL),
(464, '2024-05-13 23:03:20', '47.00', 2, NULL),
(465, '2024-05-13 23:03:21', '49.00', 3, NULL),
(466, '2024-05-13 23:03:21', '48.00', 2, NULL),
(467, '2024-05-13 23:03:22', '50.00', 3, NULL),
(468, '2024-05-13 23:03:22', '49.00', 2, NULL),
(469, '2024-05-13 23:03:23', '50.00', 2, NULL),
(470, '2024-05-13 23:03:23', '51.00', 3, NULL),
(471, '2024-05-13 23:03:24', '49.00', 2, NULL),
(472, '2024-05-13 23:03:24', '50.00', 3, NULL),
(473, '2024-05-13 23:03:25', '48.00', 2, NULL),
(474, '2024-05-13 23:03:25', '49.00', 3, NULL),
(475, '2024-05-13 23:03:26', '47.00', 2, NULL),
(476, '2024-05-13 23:03:26', '48.00', 3, NULL),
(477, '2024-05-13 23:03:27', '46.00', 2, NULL),
(478, '2024-05-13 23:03:27', '47.00', 3, NULL),
(479, '2024-05-13 23:03:28', '45.00', 2, NULL),
(480, '2024-05-13 23:03:28', '46.00', 3, NULL),
(481, '2024-05-13 23:03:29', '44.00', 2, NULL),
(482, '2024-05-13 23:03:29', '45.00', 3, NULL),
(483, '2024-05-13 23:03:30', '43.00', 2, NULL),
(484, '2024-05-13 23:03:30', '44.00', 3, NULL),
(485, '2024-05-13 23:03:31', '43.00', 3, NULL),
(486, '2024-05-13 23:03:31', '42.00', 2, NULL),
(487, '2024-05-13 23:03:32', '42.00', 3, NULL),
(488, '2024-05-13 23:03:32', '41.00', 2, NULL),
(489, '2024-05-13 23:03:33', '40.00', 2, NULL),
(490, '2024-05-13 23:03:33', '41.00', 3, NULL),
(491, '2024-05-13 23:03:35', '39.00', 2, NULL),
(492, '2024-05-13 23:03:35', '40.00', 3, NULL),
(493, '2024-05-13 23:03:36', '38.00', 2, NULL),
(494, '2024-05-13 23:03:36', '39.00', 3, NULL),
(495, '2024-05-13 23:03:37', '37.00', 2, NULL),
(496, '2024-05-13 23:03:37', '38.00', 3, NULL),
(497, '2024-05-13 23:03:38', '36.00', 2, NULL),
(498, '2024-05-13 23:03:38', '37.00', 3, NULL),
(499, '2024-05-13 23:03:39', '36.00', 3, NULL),
(500, '2024-05-13 23:03:39', '35.00', 2, NULL),
(501, '2024-05-13 23:03:40', '34.00', 2, NULL),
(502, '2024-05-13 23:03:40', '35.00', 3, NULL),
(503, '2024-05-13 23:03:41', '34.00', 3, NULL),
(504, '2024-05-13 23:03:41', '33.00', 2, NULL),
(505, '2024-05-13 23:03:42', '33.00', 3, NULL),
(506, '2024-05-13 23:03:42', '32.00', 2, NULL),
(507, '2024-05-13 23:03:43', '31.00', 2, NULL),
(508, '2024-05-13 23:03:43', '32.00', 3, NULL),
(509, '2024-05-13 23:03:44', '30.00', 2, NULL),
(510, '2024-05-13 23:03:44', '31.00', 3, NULL),
(511, '2024-05-13 23:03:45', '30.00', 3, NULL),
(512, '2024-05-13 23:03:45', '29.00', 2, NULL),
(513, '2024-05-13 23:03:46', '29.00', 3, NULL),
(514, '2024-05-13 23:03:46', '28.00', 2, NULL),
(515, '2024-05-13 23:03:47', '28.00', 3, NULL),
(516, '2024-05-13 23:03:47', '27.00', 2, NULL),
(517, '2024-05-13 23:03:48', '27.00', 3, NULL),
(518, '2024-05-13 23:03:48', '26.00', 2, NULL),
(519, '2024-05-13 23:03:49', '26.00', 3, NULL),
(520, '2024-05-13 23:03:49', '25.00', 2, NULL),
(521, '2024-05-13 23:03:50', '25.00', 3, NULL),
(522, '2024-05-13 23:03:50', '24.00', 2, NULL),
(523, '2024-05-13 23:03:51', '24.00', 3, NULL),
(524, '2024-05-13 23:03:51', '23.00', 2, NULL),
(525, '2024-05-13 23:03:52', '23.00', 3, NULL),
(526, '2024-05-13 23:03:52', '22.00', 2, NULL),
(527, '2024-05-13 23:03:53', '22.00', 3, NULL),
(528, '2024-05-13 23:03:53', '21.00', 2, NULL),
(529, '2024-05-13 23:03:54', '21.00', 3, NULL),
(530, '2024-05-13 23:03:54', '20.00', 2, NULL),
(531, '2024-05-13 23:03:55', '20.00', 3, NULL),
(532, '2024-05-13 23:03:55', '19.00', 2, NULL),
(533, '2024-05-13 23:03:56', '19.00', 3, NULL),
(534, '2024-05-13 23:03:56', '18.00', 2, NULL),
(535, '2024-05-13 23:03:57', '18.00', 3, NULL),
(536, '2024-05-13 23:03:57', '17.00', 2, NULL),
(537, '2024-05-13 23:03:58', '17.00', 3, NULL),
(538, '2024-05-13 23:03:58', '16.00', 2, NULL),
(539, '2024-05-13 23:03:59', '16.00', 3, NULL),
(540, '2024-05-13 23:03:59', '15.00', 2, NULL),
(541, '2024-05-13 23:04:00', '15.00', 3, NULL),
(542, '2024-05-13 23:04:00', '14.00', 2, NULL),
(543, '2024-05-13 23:04:01', '13.00', 2, NULL),
(544, '2024-05-13 23:04:01', '14.00', 3, NULL),
(545, '2024-05-13 23:04:02', '13.00', 3, NULL),
(546, '2024-05-13 23:04:02', '12.00', 2, NULL),
(547, '2024-05-13 23:04:03', '11.00', 2, NULL),
(548, '2024-05-13 23:04:03', '12.00', 3, NULL),
(549, '2024-05-13 23:04:04', '11.00', 3, NULL),
(550, '2024-05-13 23:04:04', '10.00', 2, NULL),
(551, '2024-05-13 23:04:05', '10.00', 3, NULL),
(552, '2024-05-13 23:04:05', '9.00', 2, NULL),
(553, '2024-05-13 23:04:06', '8.00', 2, NULL),
(554, '2024-05-13 23:04:06', '9.00', 3, NULL),
(555, '2024-05-13 23:04:07', '8.00', 3, NULL),
(556, '2024-05-13 23:04:07', '7.00', 2, NULL),
(557, '2024-05-13 23:04:08', '7.00', 3, NULL),
(558, '2024-05-13 23:04:08', '6.00', 2, NULL),
(559, '2024-05-13 23:04:09', '5.00', 2, NULL),
(560, '2024-05-13 23:04:09', '6.00', 3, NULL),
(561, '2024-05-13 23:04:10', '4.00', 2, NULL),
(562, '2024-05-13 23:04:10', '5.00', 3, NULL),
(563, '2024-05-13 23:04:11', '3.00', 2, NULL),
(564, '2024-05-13 23:04:11', '4.00', 3, NULL),
(565, '2024-05-13 23:04:12', '3.00', 3, NULL),
(566, '2024-05-13 23:04:12', '2.00', 2, NULL),
(567, '2024-05-13 23:04:13', '1.00', 2, NULL),
(568, '2024-05-13 23:04:13', '2.00', 3, NULL),
(569, '2024-05-13 23:04:14', '0.00', 2, NULL),
(570, '2024-05-13 23:04:14', '1.00', 3, NULL),
(571, '2024-05-13 23:04:15', '1.00', 2, NULL),
(572, '2024-05-13 23:04:15', '2.00', 3, NULL),
(573, '2024-05-13 23:04:16', '3.00', 3, NULL),
(574, '2024-05-13 23:04:16', '2.00', 2, NULL),
(575, '2024-05-13 23:04:17', '4.00', 3, NULL),
(576, '2024-05-13 23:04:17', '3.00', 2, NULL),
(577, '2024-05-13 23:04:18', '4.00', 2, NULL),
(578, '2024-05-13 23:04:18', '5.00', 3, NULL),
(579, '2024-05-13 23:04:19', '5.00', 2, NULL),
(580, '2024-05-13 23:04:19', '6.00', 3, NULL),
(581, '2024-05-13 23:04:20', '6.00', 2, NULL),
(582, '2024-05-13 23:04:20', '7.00', 3, NULL),
(583, '2024-05-13 23:04:21', '8.00', 3, NULL),
(584, '2024-05-13 23:04:21', '7.00', 2, NULL),
(585, '2024-05-13 23:04:22', '9.00', 3, NULL),
(586, '2024-05-13 23:04:22', '8.00', 2, NULL),
(587, '2024-05-13 23:04:23', '10.00', 3, NULL),
(588, '2024-05-13 23:04:23', '9.00', 2, NULL),
(589, '2024-05-13 23:04:24', '10.00', 2, NULL),
(590, '2024-05-13 23:04:24', '11.00', 3, NULL),
(591, '2024-05-13 23:04:25', '12.00', 3, NULL),
(592, '2024-05-13 23:04:25', '11.00', 2, NULL),
(593, '2024-05-13 23:04:26', '12.00', 2, NULL),
(594, '2024-05-13 23:04:26', '13.00', 3, NULL),
(595, '2024-05-13 23:04:27', '13.00', 2, NULL),
(596, '2024-05-13 23:04:27', '14.00', 3, NULL),
(597, '2024-05-13 23:04:28', '14.00', 2, NULL),
(598, '2024-05-13 23:04:28', '15.00', 3, NULL),
(599, '2024-05-13 23:04:29', '16.00', 3, NULL),
(600, '2024-05-13 23:04:29', '15.00', 2, NULL),
(601, '2024-05-13 23:04:30', '16.00', 2, NULL),
(602, '2024-05-13 23:04:30', '17.00', 3, NULL),
(603, '2024-05-13 23:04:31', '17.00', 2, NULL),
(604, '2024-05-13 23:04:31', '18.00', 3, NULL),
(605, '2024-05-13 23:04:32', '19.00', 3, NULL),
(606, '2024-05-13 23:04:32', '18.00', 2, NULL),
(607, '2024-05-13 23:04:33', '19.00', 2, NULL),
(608, '2024-05-13 23:04:33', '20.00', 3, NULL),
(609, '2024-05-13 23:04:34', '20.00', 2, NULL),
(610, '2024-05-13 23:04:34', '21.00', 3, NULL),
(611, '2024-05-13 23:04:35', '22.00', 3, NULL),
(612, '2024-05-13 23:04:35', '21.00', 2, NULL),
(613, '2024-05-13 23:04:36', '22.00', 2, NULL),
(614, '2024-05-13 23:04:36', '23.00', 3, NULL),
(615, '2024-05-13 23:04:37', '24.00', 3, NULL),
(616, '2024-05-13 23:04:37', '23.00', 2, NULL),
(617, '2024-05-13 23:04:38', '25.00', 3, NULL),
(618, '2024-05-13 23:04:38', '24.00', 2, NULL),
(619, '2024-05-13 23:04:39', '26.00', 3, NULL),
(620, '2024-05-13 23:04:39', '25.00', 2, NULL),
(621, '2024-05-13 23:04:40', '27.00', 3, NULL),
(622, '2024-05-13 23:04:40', '26.00', 2, NULL),
(623, '2024-05-13 23:04:41', '27.00', 2, NULL),
(624, '2024-05-13 23:04:41', '28.00', 3, NULL),
(625, '2024-05-13 23:04:42', '28.00', 2, NULL),
(626, '2024-05-13 23:04:42', '29.00', 3, NULL),
(627, '2024-05-13 23:04:43', '29.00', 2, NULL),
(628, '2024-05-13 23:04:43', '30.00', 3, NULL),
(629, '2024-05-13 23:04:44', '30.00', 2, NULL),
(630, '2024-05-13 23:04:44', '31.00', 3, NULL),
(631, '2024-05-13 23:04:45', '31.00', 2, NULL),
(632, '2024-05-13 23:04:45', '32.00', 3, NULL),
(633, '2024-05-13 23:04:46', '32.00', 2, NULL),
(634, '2024-05-13 23:04:46', '33.00', 3, NULL),
(635, '2024-05-13 23:04:47', '33.00', 2, NULL),
(636, '2024-05-13 23:04:47', '34.00', 3, NULL),
(637, '2024-05-13 23:04:48', '34.00', 2, NULL),
(638, '2024-05-13 23:04:48', '35.00', 3, NULL),
(639, '2024-05-13 23:04:49', '35.00', 2, NULL),
(640, '2024-05-13 23:04:49', '36.00', 3, NULL),
(641, '2024-05-13 23:04:50', '36.00', 2, NULL),
(642, '2024-05-13 23:04:50', '37.00', 3, NULL),
(643, '2024-05-13 23:04:51', '37.00', 2, NULL),
(644, '2024-05-13 23:04:51', '38.00', 3, NULL),
(645, '2024-05-13 23:04:52', '39.00', 3, NULL),
(646, '2024-05-13 23:04:52', '38.00', 2, NULL),
(647, '2024-05-13 23:04:53', '40.00', 3, NULL),
(648, '2024-05-13 23:04:53', '39.00', 2, NULL),
(649, '2024-05-13 23:04:54', '41.00', 3, NULL),
(650, '2024-05-13 23:04:54', '40.00', 2, NULL),
(651, '2024-05-13 23:04:55', '41.00', 2, NULL),
(652, '2024-05-13 23:04:55', '42.00', 3, NULL),
(653, '2024-05-13 23:04:56', '42.00', 2, NULL),
(654, '2024-05-13 23:04:56', '43.00', 3, NULL),
(655, '2024-05-13 23:04:57', '43.00', 2, NULL),
(656, '2024-05-13 23:04:57', '44.00', 3, NULL),
(657, '2024-05-13 23:04:58', '44.00', 2, NULL),
(658, '2024-05-13 23:04:58', '45.00', 3, NULL),
(659, '2024-05-13 23:04:59', '46.00', 3, NULL),
(660, '2024-05-13 23:04:59', '45.00', 2, NULL),
(661, '2024-05-13 23:05:00', '47.00', 3, NULL),
(662, '2024-05-13 23:05:00', '46.00', 2, NULL),
(663, '2024-05-13 23:05:01', '47.00', 2, NULL),
(664, '2024-05-13 23:05:01', '48.00', 3, NULL),
(665, '2024-05-13 23:05:02', '48.00', 2, NULL),
(666, '2024-05-13 23:05:02', '49.00', 3, NULL),
(667, '2024-05-13 23:05:03', '49.00', 2, NULL),
(668, '2024-05-13 23:05:03', '50.00', 3, NULL),
(669, '2024-05-13 23:05:04', '50.00', 2, NULL),
(670, '2024-05-13 23:05:04', '51.00', 3, NULL),
(671, '2024-05-13 23:05:05', '50.00', 3, NULL),
(672, '2024-05-13 23:05:05', '49.00', 2, NULL),
(673, '2024-05-13 23:05:06', '48.00', 2, NULL),
(674, '2024-05-13 23:05:06', '49.00', 3, NULL),
(675, '2024-05-13 23:05:07', '47.00', 2, NULL),
(676, '2024-05-13 23:05:07', '48.00', 3, NULL),
(677, '2024-05-13 23:05:08', '46.00', 2, NULL),
(678, '2024-05-13 23:05:08', '47.00', 3, NULL),
(679, '2024-05-13 23:05:09', '46.00', 3, NULL),
(680, '2024-05-13 23:05:09', '45.00', 2, NULL),
(681, '2024-05-13 23:05:10', '45.00', 3, NULL),
(682, '2024-05-13 23:05:10', '44.00', 2, NULL),
(683, '2024-05-13 23:05:11', '44.00', 3, NULL),
(684, '2024-05-13 23:05:11', '43.00', 2, NULL),
(685, '2024-05-13 23:05:12', '43.00', 3, NULL),
(686, '2024-05-13 23:05:12', '42.00', 2, NULL),
(687, '2024-05-13 23:05:13', '41.00', 2, NULL),
(688, '2024-05-13 23:05:13', '42.00', 3, NULL),
(689, '2024-05-13 23:05:14', '40.00', 2, NULL),
(690, '2024-05-13 23:05:14', '41.00', 3, NULL),
(691, '2024-05-13 23:05:15', '39.00', 2, NULL),
(692, '2024-05-13 23:05:15', '40.00', 3, NULL),
(693, '2024-05-13 23:05:16', '38.00', 2, NULL),
(694, '2024-05-13 23:05:16', '39.00', 3, NULL),
(695, '2024-05-13 23:05:17', '37.00', 2, NULL),
(696, '2024-05-13 23:05:17', '38.00', 3, NULL),
(697, '2024-05-13 23:05:18', '36.00', 2, NULL),
(698, '2024-05-13 23:05:18', '37.00', 3, NULL),
(699, '2024-05-13 23:05:19', '35.00', 2, NULL),
(700, '2024-05-13 23:05:19', '36.00', 3, NULL),
(701, '2024-05-13 23:05:20', '34.00', 2, NULL),
(702, '2024-05-13 23:05:20', '35.00', 3, NULL),
(703, '2024-05-13 23:05:21', '33.00', 2, NULL),
(704, '2024-05-13 23:05:21', '34.00', 3, NULL),
(705, '2024-05-13 23:05:22', '33.00', 3, NULL),
(706, '2024-05-13 23:05:22', '32.00', 2, NULL),
(707, '2024-05-13 23:05:23', '31.00', 2, NULL),
(708, '2024-05-13 23:05:23', '32.00', 3, NULL),
(709, '2024-05-13 23:05:24', '30.00', 2, NULL),
(710, '2024-05-13 23:05:24', '31.00', 3, NULL),
(711, '2024-05-13 23:05:25', '29.00', 2, NULL),
(712, '2024-05-13 23:05:25', '30.00', 3, NULL),
(713, '2024-05-13 23:05:26', '28.00', 2, NULL),
(714, '2024-05-13 23:05:26', '29.00', 3, NULL),
(715, '2024-05-13 23:05:27', '27.00', 2, NULL),
(716, '2024-05-13 23:05:27', '28.00', 3, NULL),
(717, '2024-05-13 23:05:28', '26.00', 2, NULL),
(718, '2024-05-13 23:05:28', '27.00', 3, NULL),
(719, '2024-05-13 23:05:29', '25.00', 2, NULL),
(720, '2024-05-13 23:05:29', '26.00', 3, NULL),
(721, '2024-05-13 23:05:31', '24.00', 2, NULL),
(722, '2024-05-13 23:05:31', '25.00', 3, NULL),
(723, '2024-05-13 23:05:32', '23.00', 2, NULL),
(724, '2024-05-13 23:05:32', '24.00', 3, NULL),
(725, '2024-05-13 23:05:33', '23.00', 3, NULL),
(726, '2024-05-13 23:05:33', '22.00', 2, NULL),
(727, '2024-05-13 23:05:34', '22.00', 3, NULL),
(728, '2024-05-13 23:05:34', '21.00', 2, NULL),
(729, '2024-05-13 23:05:35', '21.00', 3, NULL),
(730, '2024-05-13 23:05:35', '20.00', 2, NULL),
(731, '2024-05-13 23:05:36', '20.00', 3, NULL),
(732, '2024-05-13 23:05:36', '19.00', 2, NULL),
(733, '2024-05-13 23:05:37', '19.00', 3, NULL),
(734, '2024-05-13 23:05:37', '18.00', 2, NULL),
(735, '2024-05-13 23:05:38', '18.00', 3, NULL),
(736, '2024-05-13 23:05:38', '17.00', 2, NULL),
(737, '2024-05-13 23:05:39', '17.00', 3, NULL),
(738, '2024-05-13 23:05:39', '16.00', 2, NULL),
(739, '2024-05-13 23:05:40', '16.00', 3, NULL),
(740, '2024-05-13 23:05:40', '15.00', 2, NULL),
(741, '2024-05-13 23:05:41', '15.00', 3, NULL),
(742, '2024-05-13 23:05:41', '14.00', 2, NULL),
(743, '2024-05-13 23:05:42', '13.00', 2, NULL),
(744, '2024-05-13 23:05:42', '14.00', 3, NULL),
(745, '2024-05-13 23:05:43', '12.00', 2, NULL),
(746, '2024-05-13 23:05:43', '13.00', 3, NULL),
(747, '2024-05-13 23:05:44', '12.00', 3, NULL),
(748, '2024-05-13 23:05:44', '11.00', 2, NULL),
(749, '2024-05-13 23:05:45', '11.00', 3, NULL),
(750, '2024-05-13 23:05:45', '10.00', 2, NULL),
(751, '2024-05-13 23:05:46', '10.00', 3, NULL),
(752, '2024-05-13 23:05:46', '9.00', 2, NULL),
(753, '2024-05-13 23:05:47', '8.00', 2, NULL),
(754, '2024-05-13 23:05:47', '9.00', 3, NULL),
(755, '2024-05-13 23:05:48', '8.00', 3, NULL),
(756, '2024-05-13 23:05:48', '7.00', 2, NULL),
(757, '2024-05-13 23:05:49', '7.00', 3, NULL),
(758, '2024-05-13 23:05:49', '6.00', 2, NULL),
(759, '2024-05-13 23:05:50', '5.00', 2, NULL),
(760, '2024-05-13 23:05:50', '6.00', 3, NULL),
(761, '2024-05-13 23:05:51', '4.00', 2, NULL),
(762, '2024-05-13 23:05:51', '5.00', 3, NULL),
(763, '2024-05-13 23:05:52', '3.00', 2, NULL),
(764, '2024-05-13 23:05:52', '4.00', 3, NULL),
(765, '2024-05-13 23:05:53', '2.00', 2, NULL),
(766, '2024-05-13 23:05:53', '3.00', 3, NULL),
(767, '2024-05-13 23:05:54', '2.00', 3, NULL),
(768, '2024-05-13 23:05:54', '1.00', 2, NULL),
(769, '2024-05-13 23:05:55', '1.00', 3, NULL),
(770, '2024-05-13 23:05:55', '0.00', 2, NULL),
(771, '2024-05-13 23:05:56', '2.00', 3, NULL),
(772, '2024-05-13 23:05:56', '1.00', 2, NULL),
(773, '2024-05-13 23:05:57', '3.00', 3, NULL),
(774, '2024-05-13 23:05:57', '2.00', 2, NULL),
(775, '2024-05-13 23:05:58', '4.00', 3, NULL),
(776, '2024-05-13 23:05:58', '3.00', 2, NULL),
(777, '2024-05-13 23:05:59', '4.00', 2, NULL),
(778, '2024-05-13 23:05:59', '5.00', 3, NULL),
(779, '2024-05-13 23:06:00', '5.00', 2, NULL),
(780, '2024-05-13 23:06:00', '6.00', 3, NULL),
(781, '2024-05-13 23:06:01', '7.00', 3, NULL),
(782, '2024-05-13 23:06:01', '6.00', 2, NULL),
(783, '2024-05-13 23:06:02', '8.00', 3, NULL),
(784, '2024-05-13 23:06:02', '7.00', 2, NULL),
(785, '2024-05-13 23:06:03', '8.00', 2, NULL),
(786, '2024-05-13 23:06:03', '9.00', 3, NULL),
(787, '2024-05-13 23:06:04', '9.00', 2, NULL),
(788, '2024-05-13 23:06:04', '10.00', 3, NULL),
(789, '2024-05-13 23:06:05', '10.00', 2, NULL),
(790, '2024-05-13 23:06:05', '11.00', 3, NULL),
(791, '2024-05-13 23:06:06', '12.00', 3, NULL),
(792, '2024-05-13 23:06:06', '11.00', 2, NULL),
(793, '2024-05-13 23:06:07', '12.00', 2, NULL),
(794, '2024-05-13 23:06:07', '13.00', 3, NULL),
(795, '2024-05-13 23:06:08', '14.00', 3, NULL),
(796, '2024-05-13 23:06:08', '13.00', 2, NULL),
(797, '2024-05-13 23:06:09', '15.00', 3, NULL),
(798, '2024-05-13 23:06:09', '14.00', 2, NULL),
(799, '2024-05-13 23:06:10', '16.00', 3, NULL),
(800, '2024-05-13 23:06:10', '15.00', 2, NULL),
(801, '2024-05-13 23:06:11', '17.00', 3, NULL),
(802, '2024-05-13 23:06:11', '16.00', 2, NULL),
(803, '2024-05-13 23:06:12', '18.00', 3, NULL),
(804, '2024-05-13 23:06:12', '17.00', 2, NULL),
(805, '2024-05-13 23:06:13', '19.00', 3, NULL),
(806, '2024-05-13 23:06:13', '18.00', 2, NULL),
(807, '2024-05-13 23:06:14', '20.00', 3, NULL),
(808, '2024-05-13 23:06:14', '19.00', 2, NULL),
(809, '2024-05-13 23:06:15', '21.00', 3, NULL),
(810, '2024-05-13 23:06:15', '20.00', 2, NULL),
(811, '2024-05-13 23:06:16', '22.00', 3, NULL),
(812, '2024-05-13 23:06:16', '21.00', 2, NULL),
(813, '2024-05-13 23:06:17', '23.00', 3, NULL),
(814, '2024-05-13 23:06:17', '22.00', 2, NULL),
(815, '2024-05-13 23:06:18', '24.00', 3, NULL),
(816, '2024-05-13 23:06:18', '23.00', 2, NULL),
(817, '2024-05-13 23:06:19', '25.00', 3, NULL),
(818, '2024-05-13 23:06:19', '24.00', 2, NULL),
(819, '2024-05-13 23:06:20', '26.00', 3, NULL),
(820, '2024-05-13 23:06:20', '25.00', 2, NULL),
(821, '2024-05-13 23:06:21', '27.00', 3, NULL),
(822, '2024-05-13 23:06:21', '26.00', 2, NULL),
(823, '2024-05-13 23:06:22', '28.00', 3, NULL),
(824, '2024-05-13 23:06:22', '27.00', 2, NULL),
(825, '2024-05-13 23:06:23', '28.00', 2, NULL),
(826, '2024-05-13 23:06:23', '29.00', 3, NULL),
(827, '2024-05-13 23:06:24', '29.00', 2, NULL),
(828, '2024-05-13 23:06:24', '30.00', 3, NULL),
(829, '2024-05-13 23:06:25', '30.00', 2, NULL),
(830, '2024-05-13 23:06:25', '31.00', 3, NULL),
(831, '2024-05-13 23:06:26', '31.00', 2, NULL),
(832, '2024-05-13 23:06:26', '32.00', 3, NULL),
(833, '2024-05-13 23:06:27', '33.00', 3, NULL),
(834, '2024-05-13 23:06:27', '32.00', 2, NULL),
(835, '2024-05-13 23:06:28', '33.00', 2, NULL),
(836, '2024-05-13 23:06:28', '34.00', 3, NULL),
(837, '2024-05-13 23:06:29', '34.00', 2, NULL),
(838, '2024-05-13 23:06:29', '35.00', 3, NULL),
(839, '2024-05-13 23:06:30', '35.00', 2, NULL),
(840, '2024-05-13 23:06:30', '36.00', 3, NULL),
(841, '2024-05-13 23:06:31', '36.00', 2, NULL),
(842, '2024-05-13 23:06:31', '37.00', 3, NULL),
(843, '2024-05-13 23:06:32', '38.00', 3, NULL),
(844, '2024-05-13 23:06:32', '37.00', 2, NULL),
(845, '2024-05-13 23:06:33', '38.00', 2, NULL),
(846, '2024-05-13 23:06:33', '39.00', 3, NULL),
(847, '2024-05-13 23:06:34', '40.00', 3, NULL),
(848, '2024-05-13 23:06:34', '39.00', 2, NULL),
(849, '2024-05-13 23:06:35', '41.00', 3, NULL),
(850, '2024-05-13 23:06:35', '40.00', 2, NULL),
(851, '2024-05-13 23:06:36', '42.00', 3, NULL),
(852, '2024-05-13 23:06:36', '41.00', 2, NULL),
(853, '2024-05-13 23:06:37', '43.00', 3, NULL),
(854, '2024-05-13 23:06:37', '42.00', 2, NULL),
(855, '2024-05-13 23:06:38', '44.00', 3, NULL),
(856, '2024-05-13 23:06:38', '43.00', 2, NULL),
(857, '2024-05-13 23:06:39', '45.00', 3, NULL),
(858, '2024-05-13 23:06:39', '44.00', 2, NULL),
(859, '2024-05-13 23:06:40', '46.00', 3, NULL),
(860, '2024-05-13 23:06:40', '45.00', 2, NULL),
(861, '2024-05-13 23:06:41', '47.00', 3, NULL),
(862, '2024-05-13 23:06:41', '46.00', 2, NULL),
(863, '2024-05-13 23:06:42', '48.00', 3, NULL),
(864, '2024-05-13 23:06:42', '47.00', 2, NULL),
(865, '2024-05-13 23:06:43', '49.00', 3, NULL),
(866, '2024-05-13 23:06:43', '48.00', 2, NULL),
(867, '2024-05-13 23:06:44', '50.00', 3, NULL),
(868, '2024-05-13 23:06:44', '49.00', 2, NULL),
(869, '2024-05-13 23:06:45', '51.00', 3, NULL),
(870, '2024-05-13 23:06:45', '50.00', 2, NULL),
(871, '2024-05-13 23:06:46', '50.00', 3, NULL),
(872, '2024-05-13 23:06:46', '49.00', 2, NULL),
(873, '2024-05-13 23:06:47', '49.00', 3, NULL),
(874, '2024-05-13 23:06:47', '48.00', 2, NULL),
(875, '2024-05-13 23:06:48', '47.00', 2, NULL),
(876, '2024-05-13 23:06:48', '48.00', 3, NULL),
(877, '2024-05-13 23:06:49', '47.00', 3, NULL),
(878, '2024-05-13 23:06:49', '46.00', 2, NULL),
(879, '2024-05-13 23:06:50', '46.00', 3, NULL),
(880, '2024-05-13 23:06:50', '45.00', 2, NULL),
(881, '2024-05-13 23:06:51', '45.00', 3, NULL),
(882, '2024-05-13 23:06:51', '44.00', 2, NULL),
(883, '2024-05-13 23:06:52', '44.00', 3, NULL),
(884, '2024-05-13 23:06:52', '43.00', 2, NULL),
(885, '2024-05-13 23:06:53', '43.00', 3, NULL),
(886, '2024-05-13 23:06:53', '42.00', 2, NULL),
(887, '2024-05-13 23:06:54', '42.00', 3, NULL),
(888, '2024-05-13 23:06:54', '41.00', 2, NULL),
(889, '2024-05-13 23:06:55', '41.00', 3, NULL),
(890, '2024-05-13 23:06:55', '40.00', 2, NULL),
(891, '2024-05-13 23:06:56', '40.00', 3, NULL),
(892, '2024-05-13 23:06:56', '39.00', 2, NULL),
(893, '2024-05-13 23:06:57', '39.00', 3, NULL),
(894, '2024-05-13 23:06:57', '38.00', 2, NULL),
(895, '2024-05-13 23:06:58', '38.00', 3, NULL),
(896, '2024-05-13 23:06:58', '37.00', 2, NULL),
(897, '2024-05-13 23:06:59', '37.00', 3, NULL),
(898, '2024-05-13 23:06:59', '36.00', 2, NULL),
(899, '2024-05-13 23:07:00', '35.00', 2, NULL),
(900, '2024-05-13 23:07:00', '36.00', 3, NULL),
(901, '2024-05-13 23:07:01', '34.00', 2, NULL),
(902, '2024-05-13 23:07:01', '35.00', 3, NULL),
(903, '2024-05-13 23:07:02', '33.00', 2, NULL),
(904, '2024-05-13 23:07:02', '34.00', 3, NULL),
(905, '2024-05-13 23:07:04', '33.00', 3, NULL),
(906, '2024-05-13 23:07:04', '32.00', 2, NULL),
(907, '2024-05-13 23:07:05', '32.00', 3, NULL),
(908, '2024-05-13 23:07:05', '31.00', 2, NULL),
(909, '2024-05-13 23:07:06', '30.00', 2, NULL),
(910, '2024-05-13 23:07:06', '31.00', 3, NULL),
(911, '2024-05-13 23:07:07', '29.00', 2, NULL),
(912, '2024-05-13 23:07:07', '30.00', 3, NULL),
(913, '2024-05-13 23:07:08', '28.00', 2, NULL),
(914, '2024-05-13 23:07:08', '29.00', 3, NULL),
(915, '2024-05-13 23:07:09', '28.00', 3, NULL),
(916, '2024-05-13 23:07:09', '27.00', 2, NULL),
(917, '2024-05-13 23:07:10', '27.00', 3, NULL),
(918, '2024-05-13 23:07:10', '26.00', 2, NULL),
(919, '2024-05-13 23:07:11', '26.00', 3, NULL),
(920, '2024-05-13 23:07:11', '25.00', 2, NULL),
(921, '2024-05-13 23:07:12', '25.00', 3, NULL),
(922, '2024-05-13 23:07:12', '24.00', 2, NULL),
(923, '2024-05-13 23:07:13', '23.00', 2, NULL),
(924, '2024-05-13 23:07:13', '24.00', 3, NULL),
(925, '2024-05-13 23:07:14', '22.00', 2, NULL),
(926, '2024-05-13 23:07:14', '23.00', 3, NULL),
(927, '2024-05-13 23:07:15', '21.00', 2, NULL),
(928, '2024-05-13 23:07:15', '22.00', 3, NULL),
(929, '2024-05-13 23:07:16', '21.00', 3, NULL),
(930, '2024-05-13 23:07:16', '20.00', 2, NULL),
(931, '2024-05-13 23:07:17', '20.00', 3, NULL),
(932, '2024-05-13 23:07:17', '19.00', 2, NULL),
(933, '2024-05-13 23:07:18', '19.00', 3, NULL),
(934, '2024-05-13 23:07:18', '18.00', 2, NULL),
(935, '2024-05-13 23:07:19', '17.00', 2, NULL),
(936, '2024-05-13 23:07:19', '18.00', 3, NULL),
(937, '2024-05-13 23:07:20', '16.00', 2, NULL),
(938, '2024-05-13 23:07:20', '17.00', 3, NULL),
(939, '2024-05-13 23:07:21', '15.00', 2, NULL),
(940, '2024-05-13 23:07:21', '16.00', 3, NULL),
(941, '2024-05-13 23:07:22', '14.00', 2, NULL),
(942, '2024-05-13 23:07:22', '15.00', 3, NULL),
(943, '2024-05-13 23:07:23', '13.00', 2, NULL),
(944, '2024-05-13 23:07:23', '14.00', 3, NULL),
(945, '2024-05-13 23:07:24', '12.00', 2, NULL),
(946, '2024-05-13 23:07:24', '13.00', 3, NULL),
(947, '2024-05-13 23:07:25', '11.00', 2, NULL),
(948, '2024-05-13 23:07:25', '12.00', 3, NULL),
(949, '2024-05-13 23:07:26', '10.00', 2, NULL),
(950, '2024-05-13 23:07:26', '11.00', 3, NULL),
(951, '2024-05-13 23:07:27', '9.00', 2, NULL),
(952, '2024-05-13 23:07:27', '10.00', 3, NULL),
(953, '2024-05-13 23:07:28', '8.00', 2, NULL),
(954, '2024-05-13 23:07:28', '9.00', 3, NULL),
(955, '2024-05-13 23:07:29', '7.00', 2, NULL),
(956, '2024-05-13 23:07:29', '8.00', 3, NULL),
(957, '2024-05-13 23:07:30', '6.00', 2, NULL),
(958, '2024-05-13 23:07:30', '7.00', 3, NULL),
(959, '2024-05-13 23:07:31', '5.00', 2, NULL),
(960, '2024-05-13 23:07:31', '6.00', 3, NULL),
(961, '2024-05-13 23:07:32', '5.00', 3, NULL),
(962, '2024-05-13 23:07:32', '4.00', 2, NULL),
(963, '2024-05-13 23:07:33', '4.00', 3, NULL),
(964, '2024-05-13 23:07:33', '3.00', 2, NULL),
(965, '2024-05-13 23:07:34', '3.00', 3, NULL),
(966, '2024-05-13 23:07:34', '2.00', 2, NULL),
(967, '2024-05-13 23:07:35', '2.00', 3, NULL),
(968, '2024-05-13 23:07:35', '1.00', 2, NULL),
(969, '2024-05-13 23:07:36', '1.00', 3, NULL),
(970, '2024-05-13 23:07:36', '0.00', 2, NULL),
(971, '2024-05-13 23:07:37', '2.00', 3, NULL),
(972, '2024-05-13 23:07:37', '1.00', 2, NULL),
(973, '2024-05-13 23:07:38', '3.00', 3, NULL),
(974, '2024-05-13 23:07:38', '2.00', 2, NULL),
(975, '2024-05-13 23:07:39', '3.00', 2, NULL),
(976, '2024-05-13 23:07:39', '4.00', 3, NULL),
(977, '2024-05-13 23:07:40', '5.00', 3, NULL),
(978, '2024-05-13 23:07:40', '4.00', 2, NULL),
(979, '2024-05-13 23:07:41', '6.00', 3, NULL),
(980, '2024-05-13 23:07:41', '5.00', 2, NULL),
(981, '2024-05-13 23:07:42', '6.00', 2, NULL),
(982, '2024-05-13 23:07:42', '7.00', 3, NULL),
(983, '2024-05-13 23:07:43', '7.00', 2, NULL),
(984, '2024-05-13 23:07:43', '8.00', 3, NULL),
(985, '2024-05-13 23:07:44', '8.00', 2, NULL),
(986, '2024-05-13 23:07:44', '9.00', 3, NULL),
(987, '2024-05-13 23:07:45', '10.00', 3, NULL),
(988, '2024-05-13 23:07:45', '9.00', 2, NULL),
(989, '2024-05-13 23:07:46', '11.00', 3, NULL),
(990, '2024-05-13 23:07:46', '10.00', 2, NULL),
(991, '2024-05-13 23:07:47', '12.00', 3, NULL),
(992, '2024-05-13 23:07:47', '11.00', 2, NULL),
(993, '2024-05-13 23:07:48', '13.00', 3, NULL),
(994, '2024-05-13 23:07:48', '12.00', 2, NULL),
(995, '2024-05-13 23:07:49', '14.00', 3, NULL),
(996, '2024-05-13 23:07:49', '13.00', 2, NULL),
(997, '2024-05-13 23:07:50', '15.00', 3, NULL),
(998, '2024-05-13 23:07:50', '14.00', 2, NULL),
(999, '2024-05-13 23:07:51', '16.00', 3, NULL),
(1000, '2024-05-13 23:07:51', '15.00', 2, NULL),
(1001, '2024-05-13 23:07:52', '17.00', 3, NULL),
(1002, '2024-05-13 23:07:52', '16.00', 2, NULL),
(1003, '2024-05-13 23:07:53', '18.00', 3, NULL),
(1004, '2024-05-13 23:07:53', '17.00', 2, NULL),
(1005, '2024-05-13 23:07:54', '19.00', 3, NULL),
(1006, '2024-05-13 23:07:54', '18.00', 2, NULL),
(1007, '2024-05-13 23:07:55', '20.00', 3, NULL),
(1008, '2024-05-13 23:07:55', '19.00', 2, NULL),
(1009, '2024-05-13 23:07:56', '21.00', 3, NULL),
(1010, '2024-05-13 23:07:56', '20.00', 2, NULL),
(1011, '2024-05-13 23:07:57', '22.00', 3, NULL),
(1012, '2024-05-13 23:07:57', '21.00', 2, NULL),
(1013, '2024-05-13 23:07:58', '23.00', 3, NULL),
(1014, '2024-05-13 23:07:58', '22.00', 2, NULL),
(1015, '2024-05-13 23:07:59', '23.00', 2, NULL),
(1016, '2024-05-13 23:07:59', '24.00', 3, NULL),
(1017, '2024-05-13 23:08:00', '24.00', 2, NULL),
(1018, '2024-05-13 23:08:00', '25.00', 3, NULL),
(1019, '2024-05-13 23:08:01', '25.00', 2, NULL),
(1020, '2024-05-13 23:08:01', '26.00', 3, NULL),
(1021, '2024-05-13 23:08:02', '26.00', 2, NULL),
(1022, '2024-05-13 23:08:02', '27.00', 3, NULL),
(1023, '2024-05-13 23:08:03', '27.00', 2, NULL),
(1024, '2024-05-13 23:08:03', '28.00', 3, NULL),
(1025, '2024-05-13 23:08:04', '28.00', 2, NULL),
(1026, '2024-05-13 23:08:04', '29.00', 3, NULL),
(1027, '2024-05-13 23:08:05', '29.00', 2, NULL),
(1028, '2024-05-13 23:08:05', '30.00', 3, NULL),
(1029, '2024-05-13 23:08:06', '30.00', 2, NULL),
(1030, '2024-05-13 23:08:06', '31.00', 3, NULL),
(1031, '2024-05-13 23:08:07', '32.00', 3, NULL),
(1032, '2024-05-13 23:08:07', '31.00', 2, NULL),
(1033, '2024-05-13 23:08:08', '32.00', 2, NULL),
(1034, '2024-05-13 23:08:08', '33.00', 3, NULL),
(1035, '2024-05-13 23:08:09', '34.00', 3, NULL),
(1036, '2024-05-13 23:08:09', '33.00', 2, NULL),
(1037, '2024-05-13 23:08:10', '34.00', 2, NULL),
(1038, '2024-05-13 23:08:10', '35.00', 3, NULL),
(1039, '2024-05-13 23:08:11', '35.00', 2, NULL),
(1040, '2024-05-13 23:08:11', '36.00', 3, NULL),
(1041, '2024-05-13 23:08:12', '36.00', 2, NULL),
(1042, '2024-05-13 23:08:12', '37.00', 3, NULL),
(1043, '2024-05-13 23:08:13', '37.00', 2, NULL),
(1044, '2024-05-13 23:08:13', '38.00', 3, NULL),
(1045, '2024-05-13 23:08:14', '38.00', 2, NULL),
(1046, '2024-05-13 23:08:14', '39.00', 3, NULL),
(1047, '2024-05-13 23:08:15', '39.00', 2, NULL),
(1048, '2024-05-13 23:08:15', '40.00', 3, NULL),
(1049, '2024-05-13 23:08:16', '40.00', 2, NULL),
(1050, '2024-05-13 23:08:16', '41.00', 3, NULL),
(1051, '2024-05-13 23:08:17', '41.00', 2, NULL),
(1052, '2024-05-13 23:08:17', '42.00', 3, NULL),
(1053, '2024-05-13 23:08:18', '42.00', 2, NULL),
(1054, '2024-05-13 23:08:18', '43.00', 3, NULL),
(1055, '2024-05-13 23:08:19', '44.00', 3, NULL),
(1056, '2024-05-13 23:08:19', '43.00', 2, NULL),
(1057, '2024-05-13 23:08:20', '45.00', 3, NULL),
(1058, '2024-05-13 23:08:20', '44.00', 2, NULL),
(1059, '2024-05-13 23:08:21', '45.00', 2, NULL),
(1060, '2024-05-13 23:08:21', '46.00', 3, NULL),
(1061, '2024-05-13 23:08:22', '47.00', 3, NULL),
(1062, '2024-05-13 23:08:22', '46.00', 2, NULL),
(1063, '2024-05-13 23:08:23', '48.00', 3, NULL),
(1064, '2024-05-13 23:08:23', '47.00', 2, NULL),
(1065, '2024-05-13 23:08:24', '49.00', 3, NULL),
(1066, '2024-05-13 23:08:24', '48.00', 2, NULL),
(1067, '2024-05-13 23:08:25', '50.00', 3, NULL),
(1068, '2024-05-13 23:08:25', '49.00', 2, NULL),
(1069, '2024-05-13 23:08:26', '51.00', 3, NULL),
(1070, '2024-05-13 23:08:26', '50.00', 2, NULL),
(1071, '2024-05-13 23:08:27', '50.00', 3, NULL),
(1072, '2024-05-13 23:08:27', '49.00', 2, NULL),
(1073, '2024-05-13 23:08:28', '49.00', 3, NULL),
(1074, '2024-05-13 23:08:28', '48.00', 2, NULL),
(1075, '2024-05-13 23:08:29', '48.00', 3, NULL),
(1076, '2024-05-13 23:08:29', '47.00', 2, NULL),
(1077, '2024-05-13 23:08:30', '47.00', 3, NULL),
(1078, '2024-05-13 23:08:30', '46.00', 2, NULL),
(1079, '2024-05-13 23:08:31', '46.00', 3, NULL),
(1080, '2024-05-13 23:08:31', '45.00', 2, NULL),
(1081, '2024-05-13 23:08:32', '45.00', 3, NULL),
(1082, '2024-05-13 23:08:32', '44.00', 2, NULL),
(1083, '2024-05-13 23:08:33', '44.00', 3, NULL),
(1084, '2024-05-13 23:08:33', '43.00', 2, NULL),
(1085, '2024-05-13 23:08:34', '43.00', 3, NULL),
(1086, '2024-05-13 23:08:34', '42.00', 2, NULL),
(1087, '2024-05-13 23:08:35', '42.00', 3, NULL),
(1088, '2024-05-13 23:08:35', '41.00', 2, NULL);
INSERT INTO `medicoestemperatura` (`IDMedição`, `DataHora`, `Leitura`, `Sensor`, `IDExperiencia`) VALUES
(1089, '2024-05-13 23:08:36', '41.00', 3, NULL),
(1090, '2024-05-13 23:08:36', '40.00', 2, NULL),
(1091, '2024-05-13 23:08:37', '40.00', 3, NULL),
(1092, '2024-05-13 23:08:37', '39.00', 2, NULL),
(1093, '2024-05-13 23:08:38', '39.00', 3, NULL),
(1094, '2024-05-13 23:08:38', '38.00', 2, NULL),
(1095, '2024-05-13 23:08:39', '38.00', 3, NULL),
(1096, '2024-05-13 23:08:39', '37.00', 2, NULL),
(1097, '2024-05-13 23:08:40', '36.00', 2, NULL),
(1098, '2024-05-13 23:08:40', '37.00', 3, NULL),
(1099, '2024-05-13 23:08:41', '35.00', 2, NULL),
(1100, '2024-05-13 23:08:41', '36.00', 3, NULL),
(1101, '2024-05-13 23:08:42', '34.00', 2, NULL),
(1102, '2024-05-13 23:08:42', '35.00', 3, NULL),
(1103, '2024-05-13 23:08:43', '34.00', 3, NULL),
(1104, '2024-05-13 23:08:43', '33.00', 2, NULL),
(1105, '2024-05-13 23:08:44', '32.00', 2, NULL),
(1106, '2024-05-13 23:08:44', '33.00', 3, NULL),
(1107, '2024-05-13 23:08:45', '31.00', 2, NULL),
(1108, '2024-05-13 23:08:45', '32.00', 3, NULL),
(1109, '2024-05-13 23:08:46', '30.00', 2, NULL),
(1110, '2024-05-13 23:08:46', '31.00', 3, NULL),
(1111, '2024-05-13 23:08:47', '29.00', 2, NULL),
(1112, '2024-05-13 23:08:47', '30.00', 3, NULL),
(1113, '2024-05-13 23:08:48', '28.00', 2, NULL),
(1114, '2024-05-13 23:08:48', '29.00', 3, NULL),
(1115, '2024-05-13 23:08:49', '27.00', 2, NULL),
(1116, '2024-05-13 23:08:49', '28.00', 3, NULL),
(1117, '2024-05-13 23:08:50', '26.00', 2, NULL),
(1118, '2024-05-13 23:08:50', '27.00', 3, NULL),
(1119, '2024-05-13 23:08:51', '25.00', 2, NULL),
(1120, '2024-05-13 23:08:51', '26.00', 3, NULL),
(1121, '2024-05-13 23:08:52', '24.00', 2, NULL),
(1122, '2024-05-13 23:08:52', '25.00', 3, NULL),
(1123, '2024-05-13 23:08:53', '23.00', 2, NULL),
(1124, '2024-05-13 23:08:53', '24.00', 3, NULL),
(1125, '2024-05-13 23:08:54', '23.00', 3, NULL),
(1126, '2024-05-13 23:08:54', '22.00', 2, NULL),
(1127, '2024-05-13 23:08:55', '22.00', 3, NULL),
(1128, '2024-05-13 23:08:55', '21.00', 2, NULL),
(1129, '2024-05-13 23:08:56', '20.00', 2, NULL),
(1130, '2024-05-13 23:08:56', '21.00', 3, NULL),
(1131, '2024-05-13 23:08:57', '19.00', 2, NULL),
(1132, '2024-05-13 23:08:57', '20.00', 3, NULL),
(1133, '2024-05-13 23:08:58', '18.00', 2, NULL),
(1134, '2024-05-13 23:08:58', '19.00', 3, NULL),
(1135, '2024-05-13 23:09:00', '17.00', 2, NULL),
(1136, '2024-05-13 23:09:00', '18.00', 3, NULL),
(1137, '2024-05-13 23:09:01', '17.00', 3, NULL),
(1138, '2024-05-13 23:09:01', '16.00', 2, NULL),
(1139, '2024-05-13 23:09:02', '16.00', 3, NULL),
(1140, '2024-05-13 23:09:02', '15.00', 2, NULL),
(1141, '2024-05-13 23:09:03', '15.00', 3, NULL),
(1142, '2024-05-13 23:09:03', '14.00', 2, NULL),
(1143, '2024-05-13 23:09:04', '13.00', 2, NULL),
(1144, '2024-05-13 23:09:04', '14.00', 3, NULL),
(1145, '2024-05-13 23:09:05', '13.00', 3, NULL),
(1146, '2024-05-13 23:09:05', '12.00', 2, NULL),
(1147, '2024-05-13 23:09:06', '12.00', 3, NULL),
(1148, '2024-05-13 23:09:06', '11.00', 2, NULL),
(1149, '2024-05-13 23:09:07', '11.00', 3, NULL),
(1150, '2024-05-13 23:09:07', '10.00', 2, NULL),
(1151, '2024-05-13 23:09:08', '10.00', 3, NULL),
(1152, '2024-05-13 23:09:08', '9.00', 2, NULL),
(1153, '2024-05-13 23:09:09', '9.00', 3, NULL),
(1154, '2024-05-13 23:09:09', '8.00', 2, NULL),
(1155, '2024-05-13 23:09:10', '8.00', 3, NULL),
(1156, '2024-05-13 23:09:10', '7.00', 2, NULL),
(1157, '2024-05-13 23:09:11', '7.00', 3, NULL),
(1158, '2024-05-13 23:09:11', '6.00', 2, NULL),
(1159, '2024-05-13 23:09:12', '6.00', 3, NULL),
(1160, '2024-05-13 23:09:12', '5.00', 2, NULL),
(1161, '2024-05-13 23:09:13', '5.00', 3, NULL),
(1162, '2024-05-13 23:09:13', '4.00', 2, NULL),
(1163, '2024-05-13 23:09:14', '4.00', 3, NULL),
(1164, '2024-05-13 23:09:14', '3.00', 2, NULL),
(1165, '2024-05-13 23:09:15', '3.00', 3, NULL),
(1166, '2024-05-13 23:09:15', '2.00', 2, NULL),
(1167, '2024-05-13 23:09:16', '2.00', 3, NULL),
(1168, '2024-05-13 23:09:16', '1.00', 2, NULL),
(1169, '2024-05-13 23:09:17', '1.00', 3, NULL),
(1170, '2024-05-13 23:09:17', '0.00', 2, NULL),
(1171, '2024-05-13 23:09:18', '2.00', 3, NULL),
(1172, '2024-05-13 23:09:18', '1.00', 2, NULL),
(1173, '2024-05-13 23:09:19', '2.00', 2, NULL),
(1174, '2024-05-13 23:09:21', '3.00', 2, NULL),
(1175, '2024-05-13 23:09:23', '4.00', 2, NULL),
(1176, '2024-05-13 23:09:25', '5.00', 2, NULL),
(1177, '2024-05-13 23:09:27', '6.00', 2, NULL),
(1178, '2024-05-13 23:09:29', '7.00', 2, NULL),
(1179, '2024-05-13 23:09:31', '8.00', 2, NULL),
(1180, '2024-05-13 23:09:33', '9.00', 2, NULL),
(1181, '2024-05-13 23:09:35', '10.00', 2, NULL),
(1182, '2024-05-13 23:09:37', '11.00', 2, NULL),
(1183, '2024-05-13 23:09:39', '12.00', 2, NULL),
(1184, '2024-05-13 23:09:41', '13.00', 2, NULL),
(1185, '2024-05-13 23:09:43', '14.00', 2, NULL),
(1186, '2024-05-13 23:09:45', '15.00', 2, NULL),
(1187, '2024-05-13 23:09:47', '16.00', 2, NULL),
(1188, '2024-05-13 23:09:49', '17.00', 2, NULL),
(1189, '2024-05-13 23:09:51', '18.00', 2, NULL),
(1190, '2024-05-13 23:09:53', '19.00', 2, NULL),
(1191, '2024-05-13 23:09:55', '20.00', 2, NULL),
(1192, '2024-05-13 23:09:57', '21.00', 2, NULL),
(1193, '2024-05-13 23:09:59', '22.00', 2, NULL),
(1194, '2024-05-13 23:10:01', '23.00', 2, NULL),
(1195, '2024-05-13 23:10:03', '24.00', 2, NULL),
(1196, '2024-05-13 23:10:05', '25.00', 2, NULL),
(1197, '2024-05-13 23:10:07', '26.00', 2, NULL),
(1198, '2024-05-13 23:09:19', '3.00', 3, NULL),
(1199, '2024-05-13 23:09:21', '4.00', 3, NULL),
(1200, '2024-05-13 23:09:23', '5.00', 3, NULL),
(1201, '2024-05-13 23:09:25', '6.00', 3, NULL),
(1202, '2024-05-13 23:09:27', '7.00', 3, NULL),
(1203, '2024-05-13 23:09:29', '8.00', 3, NULL),
(1204, '2024-05-13 23:09:31', '9.00', 3, NULL),
(1205, '2024-05-13 23:09:33', '10.00', 3, NULL),
(1206, '2024-05-13 23:09:35', '11.00', 3, NULL),
(1207, '2024-05-13 23:09:37', '12.00', 3, NULL),
(1208, '2024-05-13 23:09:39', '13.00', 3, NULL),
(1209, '2024-05-13 23:09:41', '14.00', 3, NULL),
(1210, '2024-05-13 23:10:09', '27.00', 2, NULL),
(1211, '2024-05-13 23:09:43', '15.00', 3, NULL),
(1212, '2024-05-13 23:09:45', '16.00', 3, NULL),
(1213, '2024-05-13 23:09:47', '17.00', 3, NULL),
(1214, '2024-05-13 23:09:49', '18.00', 3, NULL),
(1215, '2024-05-13 23:09:51', '19.00', 3, NULL),
(1216, '2024-05-13 23:09:53', '20.00', 3, NULL),
(1217, '2024-05-13 23:09:55', '21.00', 3, NULL),
(1218, '2024-05-13 23:09:57', '22.00', 3, NULL),
(1219, '2024-05-13 23:09:59', '23.00', 3, NULL),
(1220, '2024-05-13 23:10:01', '24.00', 3, NULL),
(1221, '2024-05-13 23:10:03', '25.00', 3, NULL),
(1222, '2024-05-13 23:10:05', '26.00', 3, NULL),
(1223, '2024-05-13 23:10:07', '27.00', 3, NULL),
(1224, '2024-05-13 23:10:09', '28.00', 3, NULL),
(1225, '2024-05-13 23:10:10', '28.00', 2, NULL),
(1226, '2024-05-13 23:10:10', '29.00', 3, NULL),
(1227, '2024-05-13 23:10:11', '29.00', 2, NULL),
(1228, '2024-05-13 23:10:11', '30.00', 3, NULL),
(1229, '2024-05-13 23:10:13', '31.00', 3, NULL),
(1230, '2024-05-13 23:10:13', '30.00', 2, NULL),
(1231, '2024-05-13 23:10:14', '32.00', 3, NULL),
(1232, '2024-05-13 23:10:14', '31.00', 2, NULL),
(1233, '2024-05-13 23:10:15', '33.00', 3, NULL),
(1234, '2024-05-13 23:10:15', '32.00', 2, NULL),
(1235, '2024-05-13 23:10:16', '34.00', 3, NULL),
(1236, '2024-05-13 23:10:16', '33.00', 2, NULL),
(1237, '2024-05-13 23:10:17', '34.00', 2, NULL),
(1238, '2024-05-13 23:10:17', '35.00', 3, NULL),
(1239, '2024-05-13 23:10:18', '35.00', 2, NULL),
(1240, '2024-05-13 23:10:18', '36.00', 3, NULL),
(1241, '2024-05-13 23:10:19', '36.00', 2, NULL),
(1242, '2024-05-13 23:10:19', '37.00', 3, NULL),
(1243, '2024-05-13 23:10:20', '37.00', 2, NULL),
(1244, '2024-05-13 23:10:20', '38.00', 3, NULL),
(1245, '2024-05-13 23:10:21', '39.00', 3, NULL),
(1246, '2024-05-13 23:10:21', '38.00', 2, NULL),
(1247, '2024-05-13 23:10:22', '39.00', 2, NULL),
(1248, '2024-05-13 23:10:22', '40.00', 3, NULL),
(1249, '2024-05-13 23:10:23', '40.00', 2, NULL),
(1250, '2024-05-13 23:10:23', '41.00', 3, NULL),
(1251, '2024-05-13 23:10:24', '42.00', 3, NULL),
(1252, '2024-05-13 23:10:24', '41.00', 2, NULL),
(1253, '2024-05-13 23:10:25', '43.00', 3, NULL),
(1254, '2024-05-13 23:10:25', '42.00', 2, NULL),
(1255, '2024-05-13 23:10:26', '44.00', 3, NULL),
(1256, '2024-05-13 23:10:26', '43.00', 2, NULL),
(1257, '2024-05-13 23:10:27', '44.00', 2, NULL),
(1258, '2024-05-13 23:10:27', '45.00', 3, NULL),
(1259, '2024-05-13 23:10:28', '46.00', 3, NULL),
(1260, '2024-05-13 23:10:28', '45.00', 2, NULL),
(1261, '2024-05-13 23:10:29', '47.00', 3, NULL),
(1262, '2024-05-13 23:10:29', '46.00', 2, NULL),
(1263, '2024-05-13 23:10:30', '47.00', 2, NULL),
(1264, '2024-05-13 23:10:30', '48.00', 3, NULL),
(1265, '2024-05-13 23:10:31', '48.00', 2, NULL),
(1266, '2024-05-13 23:10:31', '49.00', 3, NULL),
(1267, '2024-05-13 23:10:32', '49.00', 2, NULL),
(1268, '2024-05-13 23:10:32', '50.00', 3, NULL),
(1269, '2024-05-13 23:10:33', '51.00', 3, NULL),
(1270, '2024-05-13 23:10:33', '50.00', 2, NULL),
(1271, '2024-05-13 23:10:34', '50.00', 3, NULL),
(1272, '2024-05-13 23:10:34', '49.00', 2, NULL),
(1273, '2024-05-13 23:10:35', '49.00', 3, NULL),
(1274, '2024-05-13 23:10:35', '48.00', 2, NULL),
(1275, '2024-05-13 23:10:36', '48.00', 3, NULL),
(1276, '2024-05-13 23:10:36', '47.00', 2, NULL),
(1277, '2024-05-13 23:10:37', '46.00', 2, NULL),
(1278, '2024-05-13 23:10:37', '47.00', 3, NULL),
(1279, '2024-05-13 23:10:38', '45.00', 2, NULL),
(1280, '2024-05-13 23:10:38', '46.00', 3, NULL),
(1281, '2024-05-13 23:10:39', '44.00', 2, NULL),
(1282, '2024-05-13 23:10:39', '45.00', 3, NULL),
(1283, '2024-05-13 23:10:40', '43.00', 2, NULL),
(1284, '2024-05-13 23:10:40', '44.00', 3, 41),
(1285, '2024-05-13 23:10:41', '43.00', 3, 41),
(1286, '2024-05-13 23:10:41', '42.00', 2, 41),
(1287, '2024-05-13 23:10:42', '42.00', 3, 41),
(1288, '2024-05-13 23:10:42', '41.00', 2, 41),
(1289, '2024-05-13 23:10:43', '41.00', 3, 41),
(1290, '2024-05-13 23:10:43', '40.00', 2, 41),
(1291, '2024-05-13 23:10:44', '40.00', 3, 41),
(1292, '2024-05-13 23:10:44', '39.00', 2, NULL),
(1293, '2024-05-13 23:10:45', '39.00', 3, NULL),
(1294, '2024-05-13 23:10:45', '38.00', 2, NULL),
(1295, '2024-05-13 23:10:46', '38.00', 3, NULL),
(1296, '2024-05-13 23:10:46', '37.00', 2, NULL),
(1297, '2024-05-13 23:10:47', '37.00', 3, NULL),
(1298, '2024-05-13 23:10:47', '36.00', 2, NULL),
(1299, '2024-05-13 23:10:48', '36.00', 3, NULL),
(1300, '2024-05-13 23:10:48', '35.00', 2, NULL),
(1301, '2024-05-13 23:10:49', '34.00', 2, NULL),
(1302, '2024-05-13 23:10:49', '35.00', 3, NULL),
(1303, '2024-05-13 23:10:50', '33.00', 2, NULL),
(1304, '2024-05-13 23:10:50', '34.00', 3, NULL),
(1305, '2024-05-13 23:10:51', '33.00', 3, NULL),
(1306, '2024-05-13 23:10:51', '32.00', 2, NULL),
(1307, '2024-05-13 23:10:52', '32.00', 3, NULL),
(1308, '2024-05-13 23:10:52', '31.00', 2, NULL),
(1309, '2024-05-13 23:10:53', '31.00', 3, NULL),
(1310, '2024-05-13 23:10:53', '30.00', 2, NULL),
(1311, '2024-05-13 23:10:54', '29.00', 2, NULL),
(1312, '2024-05-13 23:10:54', '30.00', 3, NULL),
(1313, '2024-05-13 23:10:55', '29.00', 3, NULL),
(1314, '2024-05-13 23:10:55', '28.00', 2, NULL),
(1315, '2024-05-13 23:10:56', '28.00', 3, NULL),
(1316, '2024-05-13 23:10:56', '27.00', 2, NULL),
(1317, '2024-05-13 23:10:57', '27.00', 3, NULL),
(1318, '2024-05-13 23:10:57', '26.00', 2, NULL),
(1319, '2024-05-13 23:10:58', '25.00', 2, NULL),
(1320, '2024-05-13 23:10:58', '26.00', 3, NULL),
(1321, '2024-05-13 23:10:59', '24.00', 2, NULL),
(1322, '2024-05-13 23:10:59', '25.00', 3, NULL),
(1323, '2024-05-13 23:11:00', '24.00', 3, NULL),
(1324, '2024-05-13 23:11:00', '23.00', 2, NULL),
(1325, '2024-05-13 23:11:01', '23.00', 3, NULL),
(1326, '2024-05-13 23:11:01', '22.00', 2, NULL),
(1327, '2024-05-13 23:11:02', '21.00', 2, NULL),
(1328, '2024-05-13 23:11:02', '22.00', 3, NULL),
(1329, '2024-05-13 23:11:03', '20.00', 2, NULL),
(1330, '2024-05-13 23:11:03', '21.00', 3, NULL),
(1331, '2024-05-13 23:11:04', '20.00', 3, NULL),
(1332, '2024-05-13 23:11:04', '19.00', 2, NULL),
(1333, '2024-05-13 23:11:05', '18.00', 2, NULL),
(1334, '2024-05-13 23:11:05', '19.00', 3, NULL),
(1335, '2024-05-13 23:11:06', '17.00', 2, NULL),
(1336, '2024-05-13 23:11:06', '18.00', 3, NULL),
(1337, '2024-05-13 23:11:07', '16.00', 2, NULL),
(1338, '2024-05-13 23:11:07', '17.00', 3, NULL),
(1339, '2024-05-13 23:11:08', '16.00', 3, NULL),
(1340, '2024-05-13 23:11:08', '15.00', 2, NULL),
(1341, '2024-05-13 23:11:09', '15.00', 3, NULL),
(1342, '2024-05-13 23:11:09', '14.00', 2, NULL),
(1343, '2024-05-13 23:11:10', '13.00', 2, NULL),
(1344, '2024-05-13 23:11:10', '14.00', 3, NULL),
(1345, '2024-05-13 23:11:11', '13.00', 3, NULL),
(1346, '2024-05-13 23:11:11', '12.00', 2, NULL),
(1347, '2024-05-13 23:11:12', '11.00', 2, NULL),
(1348, '2024-05-13 23:11:12', '12.00', 3, NULL),
(1349, '2024-05-13 23:11:13', '10.00', 2, NULL),
(1350, '2024-05-13 23:11:13', '11.00', 3, NULL),
(1351, '2024-05-13 23:11:14', '10.00', 3, NULL),
(1352, '2024-05-13 23:11:14', '9.00', 2, NULL),
(1353, '2024-05-13 23:11:15', '9.00', 3, NULL),
(1354, '2024-05-13 23:11:15', '8.00', 2, NULL),
(1355, '2024-05-13 23:11:16', '8.00', 3, NULL),
(1356, '2024-05-13 23:11:16', '7.00', 2, NULL),
(1357, '2024-05-13 23:11:17', '7.00', 3, NULL),
(1358, '2024-05-13 23:11:17', '6.00', 2, NULL),
(1359, '2024-05-13 23:11:18', '6.00', 3, NULL),
(1360, '2024-05-13 23:11:18', '5.00', 2, NULL),
(1361, '2024-05-13 23:11:19', '5.00', 3, NULL),
(1362, '2024-05-13 23:11:19', '4.00', 2, NULL),
(1363, '2024-05-13 23:11:20', '3.00', 2, NULL),
(1364, '2024-05-13 23:11:20', '4.00', 3, NULL),
(1365, '2024-05-13 23:11:21', '2.00', 2, NULL),
(1366, '2024-05-13 23:11:21', '3.00', 3, NULL),
(1367, '2024-05-13 23:11:22', '1.00', 2, NULL),
(1368, '2024-05-13 23:11:22', '2.00', 3, NULL),
(1369, '2024-05-13 23:11:23', '1.00', 3, NULL),
(1370, '2024-05-13 23:11:23', '0.00', 2, NULL),
(1371, '2024-05-13 23:11:24', '1.00', 2, NULL),
(1372, '2024-05-13 23:11:24', '2.00', 3, NULL),
(1373, '2024-05-13 23:11:25', '3.00', 3, NULL),
(1374, '2024-05-13 23:11:25', '2.00', 2, NULL),
(1375, '2024-05-13 23:11:26', '4.00', 3, NULL),
(1376, '2024-05-13 23:11:26', '3.00', 2, NULL),
(1377, '2024-05-13 23:11:27', '4.00', 2, NULL),
(1378, '2024-05-13 23:11:27', '5.00', 3, NULL),
(1379, '2024-05-13 23:11:28', '6.00', 3, NULL),
(1380, '2024-05-13 23:11:28', '5.00', 2, NULL),
(1381, '2024-05-13 23:11:29', '7.00', 3, NULL),
(1382, '2024-05-13 23:11:29', '6.00', 2, NULL),
(1383, '2024-05-13 23:11:30', '8.00', 3, NULL),
(1384, '2024-05-13 23:11:30', '7.00', 2, NULL),
(1385, '2024-05-13 23:11:31', '9.00', 3, NULL),
(1386, '2024-05-13 23:11:31', '8.00', 2, NULL),
(1387, '2024-05-13 23:11:32', '9.00', 2, NULL),
(1388, '2024-05-13 23:11:32', '10.00', 3, NULL),
(1389, '2024-05-13 23:11:33', '11.00', 3, NULL),
(1390, '2024-05-13 23:11:33', '10.00', 2, NULL),
(1391, '2024-05-13 23:11:34', '11.00', 2, NULL),
(1392, '2024-05-13 23:11:34', '12.00', 3, NULL),
(1393, '2024-05-13 23:11:35', '13.00', 3, NULL),
(1394, '2024-05-13 23:11:35', '12.00', 2, NULL),
(1395, '2024-05-13 23:11:36', '14.00', 3, NULL),
(1396, '2024-05-13 23:11:36', '13.00', 2, NULL),
(1397, '2024-05-13 23:11:37', '15.00', 3, NULL),
(1398, '2024-05-13 23:11:37', '14.00', 2, NULL),
(1399, '2024-05-13 23:11:38', '16.00', 3, NULL),
(1400, '2024-05-13 23:11:38', '15.00', 2, NULL),
(1401, '2024-05-13 23:11:39', '17.00', 3, NULL),
(1402, '2024-05-13 23:11:39', '16.00', 2, NULL),
(1403, '2024-05-13 23:11:40', '18.00', 3, NULL),
(1404, '2024-05-13 23:11:40', '17.00', 2, NULL),
(1405, '2024-05-13 23:11:41', '19.00', 3, NULL),
(1406, '2024-05-13 23:11:41', '18.00', 2, NULL),
(1407, '2024-05-13 23:11:42', '20.00', 3, NULL),
(1408, '2024-05-13 23:11:42', '19.00', 2, NULL),
(1409, '2024-05-13 23:11:43', '21.00', 3, NULL),
(1410, '2024-05-13 23:11:43', '20.00', 2, NULL),
(1411, '2024-05-13 23:11:44', '22.00', 3, NULL),
(1412, '2024-05-13 23:11:44', '21.00', 2, NULL),
(1413, '2024-05-13 23:11:45', '23.00', 3, NULL),
(1414, '2024-05-13 23:11:45', '22.00', 2, NULL),
(1415, '2024-05-13 23:11:46', '24.00', 3, NULL),
(1416, '2024-05-13 23:11:46', '23.00', 2, NULL),
(1417, '2024-05-13 23:11:47', '25.00', 3, NULL),
(1418, '2024-05-13 23:11:47', '24.00', 2, NULL),
(1419, '2024-05-13 23:11:48', '26.00', 3, NULL),
(1420, '2024-05-13 23:11:48', '25.00', 2, NULL),
(1421, '2024-05-13 23:11:49', '27.00', 3, NULL),
(1422, '2024-05-13 23:11:49', '26.00', 2, NULL),
(1423, '2024-05-13 23:11:50', '27.00', 2, NULL),
(1424, '2024-05-13 23:11:50', '28.00', 3, NULL),
(1425, '2024-05-13 23:11:51', '28.00', 2, NULL),
(1426, '2024-05-13 23:11:51', '29.00', 3, NULL),
(1427, '2024-05-13 23:11:52', '30.00', 3, NULL),
(1428, '2024-05-13 23:11:52', '29.00', 2, NULL),
(1429, '2024-05-13 23:11:53', '31.00', 3, NULL),
(1430, '2024-05-13 23:11:53', '30.00', 2, NULL),
(1431, '2024-05-13 23:11:55', '32.00', 3, NULL),
(1432, '2024-05-13 23:11:55', '31.00', 2, NULL),
(1433, '2024-05-13 23:11:56', '33.00', 3, NULL),
(1434, '2024-05-13 23:11:56', '32.00', 2, NULL),
(1435, '2024-05-13 23:11:57', '34.00', 3, NULL),
(1436, '2024-05-13 23:11:57', '33.00', 2, NULL),
(1437, '2024-05-13 23:11:58', '34.00', 2, NULL),
(1438, '2024-05-13 23:11:58', '35.00', 3, NULL),
(1439, '2024-05-13 23:11:59', '35.00', 2, NULL),
(1440, '2024-05-13 23:11:59', '36.00', 3, NULL),
(1441, '2024-05-13 23:12:00', '36.00', 2, NULL),
(1442, '2024-05-13 23:12:00', '37.00', 3, NULL),
(1443, '2024-05-13 23:12:01', '37.00', 2, NULL),
(1444, '2024-05-13 23:12:01', '38.00', 3, NULL),
(1445, '2024-05-13 23:12:02', '38.00', 2, NULL),
(1446, '2024-05-13 23:12:02', '39.00', 3, NULL),
(1447, '2024-05-13 23:12:03', '39.00', 2, NULL),
(1448, '2024-05-13 23:12:03', '40.00', 3, NULL),
(1449, '2024-05-13 23:12:04', '41.00', 3, NULL),
(1450, '2024-05-13 23:12:04', '40.00', 2, NULL),
(1451, '2024-05-13 23:12:05', '42.00', 3, NULL),
(1452, '2024-05-13 23:12:05', '41.00', 2, NULL),
(1453, '2024-05-13 23:12:06', '43.00', 3, NULL),
(1454, '2024-05-13 23:12:06', '42.00', 2, NULL),
(1455, '2024-05-13 23:12:07', '43.00', 2, NULL),
(1456, '2024-05-13 23:12:07', '44.00', 3, NULL),
(1457, '2024-05-13 23:12:08', '45.00', 3, NULL),
(1458, '2024-05-13 23:12:08', '44.00', 2, NULL),
(1459, '2024-05-13 23:12:09', '46.00', 3, NULL),
(1460, '2024-05-13 23:12:09', '45.00', 2, NULL),
(1461, '2024-05-13 23:12:10', '47.00', 3, NULL),
(1462, '2024-05-13 23:12:10', '46.00', 2, NULL),
(1463, '2024-05-13 23:12:11', '48.00', 3, NULL),
(1464, '2024-05-13 23:12:11', '47.00', 2, NULL),
(1465, '2024-05-13 23:12:12', '49.00', 3, NULL),
(1466, '2024-05-13 23:12:12', '48.00', 2, NULL),
(1467, '2024-05-13 23:12:13', '50.00', 3, NULL),
(1468, '2024-05-13 23:12:13', '49.00', 2, NULL),
(1469, '2024-05-13 23:12:14', '51.00', 3, NULL),
(1470, '2024-05-13 23:12:14', '50.00', 2, NULL),
(1471, '2024-05-13 23:12:15', '50.00', 3, NULL),
(1472, '2024-05-13 23:12:15', '49.00', 2, NULL),
(1473, '2024-05-13 23:12:16', '49.00', 3, NULL),
(1474, '2024-05-13 23:12:16', '48.00', 2, NULL),
(1475, '2024-05-13 23:12:17', '47.00', 2, NULL),
(1476, '2024-05-13 23:12:17', '48.00', 3, NULL),
(1477, '2024-05-13 23:12:18', '47.00', 3, NULL),
(1478, '2024-05-13 23:12:18', '46.00', 2, NULL),
(1479, '2024-05-13 23:12:19', '46.00', 3, NULL),
(1480, '2024-05-13 23:12:19', '45.00', 2, NULL),
(1481, '2024-05-13 23:12:20', '44.00', 2, NULL),
(1482, '2024-05-13 23:12:20', '45.00', 3, NULL),
(1483, '2024-05-13 23:12:21', '43.00', 2, NULL),
(1484, '2024-05-13 23:12:21', '44.00', 3, NULL),
(1485, '2024-05-13 23:12:22', '42.00', 2, NULL),
(1486, '2024-05-13 23:12:22', '43.00', 3, NULL),
(1487, '2024-05-13 23:12:23', '41.00', 2, NULL),
(1488, '2024-05-13 23:12:23', '42.00', 3, NULL);

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
