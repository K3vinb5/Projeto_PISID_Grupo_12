-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Apr 21, 2024 at 08:58 PM
-- Server version: 10.4.25-MariaDB
-- PHP Version: 8.1.10

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

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
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

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
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `utilizador`
--

INSERT INTO `utilizador` (`Email`, `Nome`, `Telefone`, `RemocaoLogica`) VALUES
('pedro@iscte.pt', 'Pedro', '912345678', 0);

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
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_expadecorrer`  AS SELECT `e`.`IDExperiência` AS `IDExperiência`, `e`.`Descrição` AS `Descrição`, `e`.`Investigador` AS `Investigador`, `e`.`DataHoraCriaçãoExperiência` AS `DataHoraCriaçãoExperiência`, `e`.`NúmeroRatos` AS `NúmeroRatos`, `e`.`LimiteRatosSala` AS `LimiteRatosSala`, `e`.`SegundosSemMovimento` AS `SegundosSemMovimento`, `e`.`TemperaturaMinima` AS `TemperaturaMinima`, `e`.`TemperaturaMaxima` AS `TemperaturaMaxima`, `e`.`DataHoraInicioExperiência` AS `DataHoraInicioExperiência`, `e`.`DataHoraFimExperiência` AS `DataHoraFimExperiência`, `e`.`RemocaoLogica` AS `RemocaoLogica` FROM `experiencia` AS `e` WHERE `e`.`DataHoraInicioExperiência` is not null AND `e`.`DataHoraFimExperiência` is null  ;

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
