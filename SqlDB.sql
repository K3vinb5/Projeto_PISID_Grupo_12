-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Tempo de geração: 01-Mar-2024 às 17:13
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

-- --------------------------------------------------------

--
-- Estrutura da tabela `alerta`
--

DROP TABLE IF EXISTS `alerta`;
CREATE TABLE IF NOT EXISTS `alerta` (
  `IDAlerta` int(11) NOT NULL AUTO_INCREMENT,
  `DataHora` datetime NOT NULL,
  `Sala` int(11) NOT NULL,
  `Sensor` int(11) NOT NULL,
  `Leitura` decimal(4,2) NOT NULL,
  `TipoAlerta` enum('Sem movimento','Temperatura','Capacidade da sala') NOT NULL,
  `Mensagem` varchar(100) NOT NULL,
  `DataHoraEscrita` datetime NOT NULL,
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
  `TemperaturaIdeal` decimal(4,2) NOT NULL,
  `VariaçãoTemperaturaMáxima` decimal(4,2) NOT NULL,
  `TolerânciaTemperatura` int(11) NOT NULL,
  `DataHoraInicioExperiência` datetime DEFAULT NULL,
  `DataHoraFimExperiência` datetime DEFAULT NULL,
  `SnoozeTime` int(11) NOT NULL,
  PRIMARY KEY (`IDExperiência`),
  KEY `UtilizadoresFK` (`Investigador`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Extraindo dados da tabela `experiência`
--

INSERT INTO `experiência` (`IDExperiência`, `Descrição`, `Investigador`, `DataHoraCriaçãoExperiência`, `NúmeroRatos`, `LimiteRatosSala`, `SegundosSemMovimento`, `TemperaturaIdeal`, `VariaçãoTemperaturaMáxima`, `TolerânciaTemperatura`, `DataHoraInicioExperiência`, `DataHoraFimExperiência`, `SnoozeTime`) VALUES
(1, 'Descrição Experiência', 1, '2024-02-24 23:26:18', 12, 12, 12, '12.00', '0.00', 2, '2024-02-21 22:26:00', '2024-02-21 22:33:00', 0),
(2, 'asdasd', 1, '2024-02-25 00:55:47', 12, 12, 12, '12.00', '12.10', 12, '2024-02-28 23:55:48', '2024-02-21 23:55:48', 0),
(3, 'asd', 1, '2024-02-25 03:02:38', 12, 12, 12, '12.00', '12.20', 12, '2024-02-12 03:02:12', '2024-02-13 03:02:12', 0),
(4, 'descricao', 1, '2024-02-25 03:50:44', 20, 20, 20, '20.00', '1.10', 10, '2024-02-12 03:02:12', '2024-02-13 03:02:12', 0),
(5, 'descricao', 1, '2024-02-25 03:58:18', 20, 20, 20, '20.00', '1.10', 10, '2024-02-12 03:02:12', '2024-02-13 03:02:12', 0),
(6, 'descricao', 2, '2024-02-25 04:00:58', 20, 20, 20, '20.00', '1.10', 10, '2024-02-12 03:02:12', '2024-02-13 03:02:12', 0),
(7, 'descricao', 1, '2024-02-25 04:06:37', 20, 20, 20, '20.00', '1.10', 10, '2024-02-12 03:02:12', '2024-02-13 03:02:12', 0),
(8, 'descricao', 2, '2024-02-25 04:07:04', 20, 20, 20, '20.00', '1.10', 10, '2024-02-12 03:02:12', '2024-02-13 03:02:12', 0),
(9, 'descricao', 2, '2024-02-26 15:11:01', 20, 20, 20, '20.00', '20.00', 10, '2024-02-12 03:02:12', '2024-02-13 03:02:12', 0);

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
  PRIMARY KEY (`IDMedição`),
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
  PRIMARY KEY (`IDMedição`),
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
  `TipoUtilizador` enum('Investigador','Administrador de Aplicação','Administrador de Base de Dados') NOT NULL,
  `EmailUtilizador` varchar(50) NOT NULL,
  `PasswordUtilizador` varchar(200) NOT NULL,
  PRIMARY KEY (`IDUtilizador`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Extraindo dados da tabela `utilizador`
--

INSERT INTO `utilizador` (`IDUtilizador`, `NomeUtilizador`, `TelefoneUtilizador`, `TipoUtilizador`, `EmailUtilizador`, `PasswordUtilizador`) VALUES
(1, 'admin', '987654321', 'Administrador de Base de Dados', 'admin@email.com', 'admin'),
(2, 'Kevin', '987654322', 'Investigador', 'kevin@email.com', 'kevin');

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
