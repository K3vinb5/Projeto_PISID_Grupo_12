-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Tempo de geração: 29-Abr-2024 às 22:54
-- Versão do servidor: 10.4.25-MariaDB
-- versão do PHP: 8.1.6

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

	DELETE FROM experiencia
	WHERE IDExperiencia = idExperiencia;
    
    SELECT ROW_COUNT();

END$$

DROP PROCEDURE IF EXISTS `ApagarUtilizador`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ApagarUtilizador` (IN `email` VARCHAR(50))   BEGIN

	UPDATE utilizador u
    SET u.RemocaoLogica = TRUE
    WHERE u.EmailUtilizador = email;
    
    SELECT ROW_COUNT();
    
END$$

DROP PROCEDURE IF EXISTS `AtribuirExperienciaInvestigador`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `AtribuirExperienciaInvestigador` (IN `idExperiencia` INT, IN `idInvestigador` INT)   BEGIN

	DECLARE countExp, countUti, idExperienciaDecorrer INT;

    SELECT COUNT(*) INTO countExp FROM experiência e WHERE e.IDExperiencia = idExperiencia;
    SELECT COUNT(*) INTO countUti FROM utilizador u WHERE u.IDUtilizador = idInvestigador;
	
    IF countExp>0 AND countUti>0 THEN
    	CALL ObterExperienciaADecorrer(idExperienciaDecorrer);
        IF idExperienciaDecorrer != idExperiencia THEN
        	UPDATE experiência e
            SET e.Investigador = idInvestigador
            WHERE e.IDExperiencia = idExperiencia;
		END IF;
	END IF;
    
    SELECT ROW_COUNT();
    
END$$

DROP PROCEDURE IF EXISTS `AtualizarNumRatosSala`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `AtualizarNumRatosSala` (IN `salaOrigem` INT, IN `salaDestino` INT, IN `idExperiencia` INT)   BEGIN

	DECLARE valorOrigem, valorDestino INT;
    SELECT m.NúmeroRatosFinal INTO valorOrigem FROM medicoessala m WHERE m.IDExperiencia = idExperiencia AND m.Sala = salaOrigem LIMIT 1;
    SELECT m.NúmeroRatosFinal INTO valorDestino FROM medicoessala m WHERE m.IDExperiencia = idExperiencia AND m.Sala = salaDestino LIMIT 1;
    
	UPDATE medicoessala
    SET NúmeroRatosFinal = (valorOrigem - 1)
    WHERE Sala = salaOrigem AND IDExperiencia = idExperiencia;
    
    UPDATE medicoessala
    SET NúmeroRatosFinal = (valorDestino + 1)
    WHERE Sala = salaDestino AND IDExperiencia = idExperiencia;

END$$

DROP PROCEDURE IF EXISTS `ComecarTerminarExperienca`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ComecarTerminarExperienca` (IN `idExperiencia` INT)   BEGIN

	DECLARE idExperienciaDecorrer INT;
    CALL ObterExperienciaADecorrer(idExperiencia);
    
    IF idExperienciaDecorrer IS NULL THEN
    	UPDATE experiencia e
        SET e.DataHoraInicioExperiência = NOW()
        WHERE e.IDExperiencia = idExperiencia;
	ELSE
    	IF idExperiencia = idExperienciaDecorrer THEN
        	UPDATE experiencia e
            SET e.DataHoraFimExperiência = NOW()
            WHERE e.IDExperiencia = idExperiencia;
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
        SET u.Email = IFNULL(novoEmailUtilizador, e.Email), 
            u.Nome = IFNULL(novoNomeUtilizador, e.Nome), 
            u.Telefone = IFNULL(novoTelefoneUtilizador, e.Telefone)
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
        
        IF novoEmailUtilizador IS NOT NULL THEN
        	SET @sql = CONCAT('RENAME USER ', QUOTE(emailUtilizador), '@', QUOTE('localhost'), ' TO ', QUOTE(novoEmailUtilizador), '@', QUOTE('localhost'));
            PREPARE stmt FROM @sql;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
        END IF;
    ELSE
        UPDATE utilizador u
        SET u.Email = IFNULL(novoEmailUtilizador, e.Email), 
            u.Nome = IFNULL(novoNomeUtilizador, e.Nome), 
            u.Telefone = IFNULL(novoTelefoneUtilizador, e.Telefone)
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
        
        IF novoEmailUtilizador IS NOT NULL THEN
        	SET @sql = CONCAT('RENAME USER ', QUOTE(utilizadorLogado), '@', QUOTE('localhost'), ' TO ', QUOTE(novoEmailUtilizador), '@', QUOTE('localhost'));
            PREPARE stmt FROM @sql;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
        END IF;
    END IF;
    
    SELECT ROW_COUNT();

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
    	INSERT INTO alerta (DataHora, Sensor, Leitura, TipoAlerta, Mensagem) 
        VALUES (NOW(), sensor, leitura, tipoAlerta, mensagem);
	END IF;
    
    SELECT ROW_COUNT();

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

    SELECT ROW_COUNT();

END$$

DROP PROCEDURE IF EXISTS `InserirNaoConformes`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `InserirNaoConformes` (IN `registoRecebido` VARCHAR(255), IN `TipoMedicao` ENUM('Temperatura','Movimento'), IN `tipoDado` ENUM('Outlier','Dado Errado'))   BEGIN

	INSERT INTO medicoesnaoconformes (RegistoRecebido, TipoMedicao, TipoDado)
    VALUES (registoRecebido, TipoMedicao, tipoDado);
    
    SELECT ROW_COUNT();

END$$

DROP PROCEDURE IF EXISTS `InserirTemperatura`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `InserirTemperatura` (IN `Hora` DATETIME, IN `Leitura` DECIMAL(4,2), IN `Sensor` INT)   BEGIN

    INSERT INTO medicoestemperatura (DataHora, Leitura, Sensor)
    VALUES (Hora, Leitura, Sensor);

    SELECT ROW_COUNT();

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
    
    SELECT ROW_COUNT();

END$$

DROP PROCEDURE IF EXISTS `ObterExperiencia`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ObterExperiencia` (IN `idExperiencia` INT)   BEGIN

	SELECT * FROM experiencia e WHERE e.IDExperiencia = idExperiencia;
    
END$$

DROP PROCEDURE IF EXISTS `ObterExperienciaADecorrer`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `ObterExperienciaADecorrer` (OUT `idExperiencia` INT)   BEGIN

    SELECT IDExperiencia INTO idExperiencia FROM v_expadecorrer LIMIT 1;
    
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

	SELECT * FROM medicoessala m WHERE m.IDExperiencia = idExperiencia;
    
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
-- Estrutura da tabela `alerta`
--

DROP TABLE IF EXISTS `alerta`;
CREATE TABLE IF NOT EXISTS `alerta` (
  `IDAlerta` int(11) NOT NULL AUTO_INCREMENT,
  `DataHora` datetime NOT NULL,
  `Sala` int(11) DEFAULT NULL,
  `IDSensor` int(11) DEFAULT NULL,
  `Leitura` decimal(4,2) DEFAULT NULL,
  `TipoAlerta` enum('Sem movimento','Temperatura','Capacidade da sala') NOT NULL,
  `Mensagem` varchar(100) NOT NULL,
  `IDExperiencia` int(11) DEFAULT NULL,
  PRIMARY KEY (`IDAlerta`),
  KEY `ExperienciaFK` (`IDExperiencia`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Acionadores `alerta`
--
DROP TRIGGER IF EXISTS `AlertaInsertBefore`;
DELIMITER $$
CREATE TRIGGER `AlertaInsertBefore` BEFORE INSERT ON `alerta` FOR EACH ROW BEGIN

	DECLARE idExperiencia INT;
    CALL ObterExperienciaADecorrer(idExperiencia);
    
    SET new.IDExperiencia = idExperiencia;

	IF NOT EXISTS (SELECT * FROM sensor WHERE IDSensor = new.IDSensor AND IsActive = TRUE) THEN
    	SET new.IDSensor = (SELECT s.IDSensor FROM sensor s WHERE s.Nome = 'Not Defined' AND s.IDTipoSensor = (SELECT * FROM tiposensor t WHERE T.Designacao = 'Not Defined'));
    END IF;

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `experiencia`
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
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=utf8;

--
-- Extraindo dados da tabela `experiencia`
--

INSERT INTO `experiencia` (`IDExperiencia`, `Descrição`, `DataHoraCriaçãoExperiência`, `NúmeroRatos`, `LimiteRatosSala`, `SegundosSemMovimento`, `TemperaturaMinima`, `TemperaturaMaxima`, `TemperaturaAvisoMaximo`, `TemperaturaAvisoMinimo`, `DataHoraInicioExperiência`, `DataHoraFimExperiência`, `Investigador`) VALUES
(24, 'Nova desc', '2024-04-22 17:53:48', 44, 15, 45, '10.00', '25.00', '15.00', '11.00', NULL, NULL, 'pedro@iscte.pt'),
(25, 'teste', '2024-04-22 17:56:21', 50, 8, 30, '5.00', '20.00', '18.00', '7.00', NULL, NULL, 'pedro@iscte.pt'),
(26, 'Experiencia editada 123', '2024-04-22 21:47:49', 20, 5, 10, '19.00', '24.00', '24.00', '19.00', NULL, NULL, 'pedro@iscte.pt'),
(27, 'teste 1', '2024-04-22 22:35:13', 10, 2, 10, '15.00', '25.00', '20.00', '19.00', NULL, NULL, 'fatima@iscte.pt'),
(28, 'Experiencia com email NULL', '2024-04-22 22:35:55', 10, 2, 10, '15.00', '25.00', '20.00', '19.00', NULL, NULL, 'fatima@iscte.pt');

--
-- Acionadores `experiencia`
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
    
    WHILE counter < 10 DO
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
    	IF NOT EXISTS (SELECT * FROM mysql.roles_mapping WHERE User = utilizador AND Host = 'localhost' AND Role = 'AdministradorAplicacao') THEN
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
-- Estrutura da tabela `medicoesnaoconformes`
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Acionadores `medicoesnaoconformes`
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
-- Estrutura da tabela `medicoespassagem`
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Acionadores `medicoespassagem`
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
-- Estrutura da tabela `medicoessala`
--

DROP TABLE IF EXISTS `medicoessala`;
CREATE TABLE IF NOT EXISTS `medicoessala` (
  `IDMedição` int(11) NOT NULL AUTO_INCREMENT,
  `IDExperiencia` int(11) DEFAULT NULL,
  `NúmeroRatosFinal` int(11) NOT NULL,
  `Sala` int(11) NOT NULL,
  PRIMARY KEY (`IDMedição`),
  KEY `ExpSalaFK` (`IDExperiencia`)
) ENGINE=InnoDB AUTO_INCREMENT=49 DEFAULT CHARSET=utf8;

--
-- Extraindo dados da tabela `medicoessala`
--

INSERT INTO `medicoessala` (`IDMedição`, `IDExperiencia`, `NúmeroRatosFinal`, `Sala`) VALUES
(1, 24, 44, 1),
(2, 24, 0, 2),
(3, 24, 0, 3),
(4, 24, 0, 4),
(5, 24, 0, 5),
(6, 24, 0, 6),
(7, 24, 0, 7),
(8, 24, 0, 8),
(9, 24, 0, 9),
(10, 24, 0, 10),
(12, 25, 50, 1),
(13, 25, 0, 2),
(14, 25, 0, 3),
(15, 25, 0, 4),
(16, 25, 0, 5),
(17, 25, 0, 6),
(18, 25, 0, 7),
(19, 25, 0, 8),
(20, 25, 0, 9),
(21, 25, 0, 10),
(22, 26, 20, 1),
(23, 26, 0, 2),
(24, 26, 0, 3),
(25, 26, 0, 4),
(26, 26, 0, 5),
(27, 26, 0, 6),
(28, 26, 0, 7),
(29, 26, 0, 8),
(30, 26, 0, 9),
(31, 27, 10, 1),
(32, 27, 0, 2),
(33, 27, 0, 3),
(34, 27, 0, 4),
(35, 27, 0, 5),
(36, 27, 0, 6),
(37, 27, 0, 7),
(38, 27, 0, 8),
(39, 27, 0, 9),
(40, 28, 10, 1),
(41, 28, 0, 2),
(42, 28, 0, 3),
(43, 28, 0, 4),
(44, 28, 0, 5),
(45, 28, 0, 6),
(46, 28, 0, 7),
(47, 28, 0, 8),
(48, 28, 0, 9);

--
-- Acionadores `medicoessala`
--
DROP TRIGGER IF EXISTS `MedicoesSalaInsertBefore`;
DELIMITER $$
CREATE TRIGGER `MedicoesSalaInsertBefore` BEFORE INSERT ON `medicoessala` FOR EACH ROW BEGIN

	DECLARE idExperiencia INT;
    CALL ObterExperienciaADecorrer(idExperiencia);
    
    SET new.IDExperiencia = idExperiencia;

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `medicoestemperatura`
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Acionadores `medicoestemperatura`
--
DROP TRIGGER IF EXISTS `MedicoesTemperaturaInsertBefore`;
DELIMITER $$
CREATE TRIGGER `MedicoesTemperaturaInsertBefore` BEFORE INSERT ON `medicoestemperatura` FOR EACH ROW BEGIN

	DECLARE idExperiencia INT;
    CALL ObterExperienciaADecorrer(idExperiencia);
    
    SET new.IDExperiencia = idExperiencia;
    
    IF NOT EXISTS (SELECT * FROM sensor WHERE IDSensor = new.Sensor AND IDTipoSensor = (SELECT t.IDTipoSensor FROM tiposensor t WHERE T.Designacao = 'Temperatura') AND IsActive = TRUE) THEN
    
   -- IF NOT EXISTS (SELECT * FROM sensor WHERE (Nome = new.Sensor OR IDSensor = new.Sensor) AND IDTipoSensor = (SELECT t.IDTipoSensor FROM tiposensor t WHERE T.Designacao = 'Temperatura') AND IsActive = TRUE) THEN
    	-- SET new.Sensor = (SELECT s.IDSensor FROM sensor s WHERE s.Nome = 'Not Defined' AND s.IDTipoSensor = (SELECT * FROM tiposensor t WHERE T.Designacao = 'Not Defined'));
    	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Sensor não reconhecivel!';
    ELSE
    	SET new.Sensor = (SELECT s.IDSensor FROM sensor s WHERE s.IDSensor = new.Sensor AND IDTipoSensor = (SELECT t.IDTipoSensor FROM tiposensor t WHERE T.Designacao = 'Temperatura') AND IsActive = TRUE);
    END IF;

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `parametroadicional`
--

DROP TABLE IF EXISTS `parametroadicional`;
CREATE TABLE IF NOT EXISTS `parametroadicional` (
  `IDParâmetro` int(11) NOT NULL AUTO_INCREMENT,
  `NrRegistosOutlierTemperatura` int(11) NOT NULL DEFAULT 25,
  `NrRegistosAlertaTemperatura` int(11) NOT NULL DEFAULT 15,
  `ControloSpamTemperatura` int(11) NOT NULL DEFAULT 30,
  `ControloSpamMovimentos` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`IDParâmetro`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

--
-- Extraindo dados da tabela `parametroadicional`
--

INSERT INTO `parametroadicional` (`IDParâmetro`, `NrRegistosOutlierTemperatura`, `NrRegistosAlertaTemperatura`, `ControloSpamTemperatura`, `ControloSpamMovimentos`) VALUES
(1, 25, 15, 30, 0);

--
-- Acionadores `parametroadicional`
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
-- Estrutura da tabela `sensor`
--

DROP TABLE IF EXISTS `sensor`;
CREATE TABLE IF NOT EXISTS `sensor` (
  `IDSensor` int(11) NOT NULL AUTO_INCREMENT,
  `Nome` varchar(50) NOT NULL,
  `IDTipoSensor` int(11) NOT NULL,
  `IsActive` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`IDSensor`),
  KEY `IDTipoSensor` (`IDTipoSensor`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

--
-- Extraindo dados da tabela `sensor`
--

INSERT INTO `sensor` (`IDSensor`, `Nome`, `IDTipoSensor`, `IsActive`) VALUES
(1, 'Not Defined', 1, 1),
(2, '1', 2, 1),
(3, '2', 2, 1);

-- --------------------------------------------------------

--
-- Estrutura da tabela `tiposensor`
--

DROP TABLE IF EXISTS `tiposensor`;
CREATE TABLE IF NOT EXISTS `tiposensor` (
  `IDTipoSensor` int(11) NOT NULL AUTO_INCREMENT,
  `Designacao` varchar(50) NOT NULL,
  PRIMARY KEY (`IDTipoSensor`),
  UNIQUE KEY `Designacao` (`Designacao`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

--
-- Extraindo dados da tabela `tiposensor`
--

INSERT INTO `tiposensor` (`IDTipoSensor`, `Designacao`) VALUES
(3, 'Movimento'),
(1, 'Not Defined'),
(2, 'Temperatura');

--
-- Acionadores `tiposensor`
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
-- Estrutura da tabela `utilizador`
--

DROP TABLE IF EXISTS `utilizador`;
CREATE TABLE IF NOT EXISTS `utilizador` (
  `Email` varchar(200) NOT NULL,
  `Nome` varchar(100) NOT NULL,
  `Telefone` varchar(12) DEFAULT NULL,
  `RemocaoLogica` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`Email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Extraindo dados da tabela `utilizador`
--

INSERT INTO `utilizador` (`Email`, `Nome`, `Telefone`, `RemocaoLogica`) VALUES
('admin@iscte.pt', 'Admin', '921345678', 0),
('fatima@iscte.pt', 'Fatima', '918649728', 0),
('pedro@iscte.pt', 'Pedro', '912345678', 0),
('system@iscte.pt', 'System', NULL, 0);

-- --------------------------------------------------------

--
-- Estrutura stand-in para vista `v_expadecorrer`
-- (Veja abaixo para a view atual)
--
DROP VIEW IF EXISTS `v_expadecorrer`;
CREATE TABLE IF NOT EXISTS `v_expadecorrer` (
`IDExperiencia` int(11)
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
);

-- --------------------------------------------------------

--
-- Estrutura stand-in para vista `v_utilizador`
-- (Veja abaixo para a view atual)
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
-- Estrutura para vista `v_expadecorrer`
--
DROP TABLE IF EXISTS `v_expadecorrer`;

DROP VIEW IF EXISTS `v_expadecorrer`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_expadecorrer`  AS SELECT `e`.`IDExperiencia` AS `IDExperiencia`, `e`.`Descrição` AS `Descrição`, `e`.`Investigador` AS `Investigador`, `e`.`DataHoraCriaçãoExperiência` AS `DataHoraCriaçãoExperiência`, `e`.`NúmeroRatos` AS `NúmeroRatos`, `e`.`LimiteRatosSala` AS `LimiteRatosSala`, `e`.`SegundosSemMovimento` AS `SegundosSemMovimento`, `e`.`TemperaturaMinima` AS `TemperaturaMinima`, `e`.`TemperaturaMaxima` AS `TemperaturaMaxima`, `e`.`DataHoraInicioExperiência` AS `DataHoraInicioExperiência`, `e`.`DataHoraFimExperiência` AS `DataHoraFimExperiência` FROM `experiencia` AS `e` WHERE `e`.`DataHoraInicioExperiência` is not null AND `e`.`DataHoraFimExperiência` is null  ;

-- --------------------------------------------------------

--
-- Estrutura para vista `v_utilizador`
--
DROP TABLE IF EXISTS `v_utilizador`;

DROP VIEW IF EXISTS `v_utilizador`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_utilizador`  AS SELECT `u`.`Email` AS `Email`, `u`.`Nome` AS `Nome`, `u`.`Telefone` AS `Telefone`, `u`.`RemocaoLogica` AS `RemocaoLogica` FROM `utilizador` AS `u` WHERE `u`.`Email` = substring_index(user(),'@',2)  ;

--
-- Restrições para despejos de tabelas
--

--
-- Limitadores para a tabela `alerta`
--
ALTER TABLE `alerta`
  ADD CONSTRAINT `ExperienciaFK` FOREIGN KEY (`IDExperiencia`) REFERENCES `experiencia` (`IDExperiencia`) ON UPDATE CASCADE;

--
-- Limitadores para a tabela `experiencia`
--
ALTER TABLE `experiencia`
  ADD CONSTRAINT `experiencia_ibfk_1` FOREIGN KEY (`Investigador`) REFERENCES `utilizador` (`Email`) ON UPDATE CASCADE;

--
-- Limitadores para a tabela `medicoesnaoconformes`
--
ALTER TABLE `medicoesnaoconformes`
  ADD CONSTRAINT `medicoesnaoconformes_ibfk_1` FOREIGN KEY (`IDExperiencia`) REFERENCES `experiencia` (`IDExperiencia`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Limitadores para a tabela `medicoespassagem`
--
ALTER TABLE `medicoespassagem`
  ADD CONSTRAINT `medicoespassagem_ibfk_1` FOREIGN KEY (`IDExperiencia`) REFERENCES `experiencia` (`IDExperiencia`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Limitadores para a tabela `medicoessala`
--
ALTER TABLE `medicoessala`
  ADD CONSTRAINT `medicoessala_ibfk_1` FOREIGN KEY (`IDExperiencia`) REFERENCES `experiencia` (`IDExperiencia`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Limitadores para a tabela `medicoestemperatura`
--
ALTER TABLE `medicoestemperatura`
  ADD CONSTRAINT `medicoestemperatura_ibfk_1` FOREIGN KEY (`IDExperiencia`) REFERENCES `experiencia` (`IDExperiencia`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `medicoestemperatura_ibfk_2` FOREIGN KEY (`Sensor`) REFERENCES `sensor` (`IDSensor`) ON UPDATE CASCADE;

--
-- Limitadores para a tabela `sensor`
--
ALTER TABLE `sensor`
  ADD CONSTRAINT `sensor_ibfk_1` FOREIGN KEY (`IDTipoSensor`) REFERENCES `tiposensor` (`IDTipoSensor`) ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;