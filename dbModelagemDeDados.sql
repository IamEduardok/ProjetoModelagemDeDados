SELECT database();

INSERT INTO unidade (nome, tipo, cnpj, telefone, email, endereco) 
VALUES ('Hospital Central','Hospital','12345678000199','(11)99999-9999','contato@hospital.com','Rua Central, 100');

select  * FROM unidade WHERE NOME = 'Hospital Central';

INSERT INTO Especialidade(nome)
VALUES
('Cardiologia'),
('Ortopedia'),
('Pediatria');

select *  from especialidade where nome  = 'ortopedia';


INSERT INTO Medico
(nome,crm,telefone,email,unidade_id)
VALUES
('Joao Silva',
'CRM12345',
'(11)98888-8888',
'joao@hospital.com',
1);

INSERT INTO Medico_Especialidade
VALUES
(1,1);

INSERT INTO Paciente
(nome,cpf,data_nasc,telefone,email,endereco)
VALUES
('Maria Souza',
'12345678901',
'1995-05-20',
'(11)97777-7777',
'maria@email.com',
'Rua B, 200');

INSERT INTO Prontuario
(paciente_id,medico_id,data_registro,cid10)
VALUES
(1,1,NOW(),'I10');

INSERT INTO Medicamento
(nome,principio_ativo,apresentacao)
VALUES
('Dipirona',
'Dipirona Sodica',
'500mg');

INSERT INTO Prescricao
(prontuario_id,medico_id,data_prescricao)
VALUES
(1,1,CURDATE());

INSERT INTO Item_Prescricao
(prescricao_id,medicamento_id,dosagem,frequencia,duracao_dias,via)
VALUES
(1,1,'500mg','8/8h',5,'Oral');

SELECT * FROM Unidade;

SELECT * FROM Unidade;
SELECT * FROM Especialidade;
SELECT * FROM Medico;
SELECT * FROM Paciente;
SELECT * FROM Prontuario; 
SELECT * FROM Medicamento;
SELECT * FROM Prescricao;
SELECT * FROM Item_Prescricao;

USE hospitaldb;

USE hospitaldb;
 
-- ============================================================
-- PASSO 1 – REMOVER TABELAS QUE NÃO EXISTEM NO DIAGRAMA
-- (drop na ordem correta para respeitar FKs)
-- ============================================================
 
-- item_prescricao depende de prescricao → dropar primeiro
DROP TABLE IF EXISTS item_prescricao;
 
-- medico_especialidade depende de medico e especialidade
DROP TABLE IF EXISTS medico_especialidade;
 
-- especialidade não consta no diagrama
DROP TABLE IF EXISTS especialidade;
 
-- ============================================================
-- PASSO 2 – CRIAR TABELAS QUE FALTAM NO BANCO
-- (ordem respeita dependências de FK)
-- ============================================================
 
-- ------------------------------------------------------------
-- ESTOQUE  (depende de unidade e medicamento)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS estoque (
    id               INT            NOT NULL AUTO_INCREMENT,
    unidade_id       INT            NOT NULL,
    medicamento_id   INT            NOT NULL,
    quantidade       INT            NOT NULL DEFAULT 0,
    lote             VARCHAR(50),
    validade         DATE,
    preco_unit       DECIMAL(10,2),
    data_atualizacao DATETIME       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    CONSTRAINT fk_estoque_unidade      FOREIGN KEY (unidade_id)     REFERENCES unidade(id),
    CONSTRAINT fk_estoque_medicamento  FOREIGN KEY (medicamento_id) REFERENCES medicamento(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
 
-- ------------------------------------------------------------
-- AGENDA  (depende de medico e unidade)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS agenda (
    id             INT          NOT NULL AUTO_INCREMENT,
    medico_id      INT          NOT NULL,
    unidade_id     INT          NOT NULL,
    data           DATE         NOT NULL,
    hora_inicio    TIME         NOT NULL,
    hora_fim       TIME         NOT NULL,
    status         VARCHAR(30)  DEFAULT 'disponivel',
    tipo_consulta  VARCHAR(50),
    obs            VARCHAR(200),
    PRIMARY KEY (id),
    CONSTRAINT fk_agenda_medico   FOREIGN KEY (medico_id)  REFERENCES medico(id),
    CONSTRAINT fk_agenda_unidade  FOREIGN KEY (unidade_id) REFERENCES unidade(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
 
-- ------------------------------------------------------------
-- CONVENIO
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS convenio (
    id        INT          NOT NULL AUTO_INCREMENT,
    nome      VARCHAR(100) NOT NULL,
    tipo      VARCHAR(50),
    ans       VARCHAR(20)  UNIQUE,
    telefone  VARCHAR(20),
    email     VARCHAR(100),
    cobertura TEXT,
    ativa     TINYINT      NOT NULL DEFAULT 1,
    PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
 
-- ------------------------------------------------------------
-- PACIENTE_CONVENIO  (depende de paciente e convenio)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS paciente_convenio (
    id                   INT         NOT NULL AUTO_INCREMENT,
    paciente_id          INT         NOT NULL,
    convenio_id          INT         NOT NULL,
    numero_carteirinha   VARCHAR(50),
    plano                VARCHAR(80),
    data_inicio          DATE,
    data_fim             DATE,
    titular              TINYINT     DEFAULT 1,
    ativa                TINYINT     NOT NULL DEFAULT 1,
    PRIMARY KEY (id),
    CONSTRAINT fk_pacconv_paciente  FOREIGN KEY (paciente_id) REFERENCES paciente(id),
    CONSTRAINT fk_pacconv_convenio  FOREIGN KEY (convenio_id) REFERENCES convenio(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
 
-- ------------------------------------------------------------
-- FATURA  (depende de paciente e convenio)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS fatura (
    id               INT            NOT NULL AUTO_INCREMENT,
    paciente_id      INT            NOT NULL,
    convenio_id      INT,
    data_emissao     DATE           NOT NULL,
    valor_total      DECIMAL(10,2)  NOT NULL DEFAULT 0,
    desconto         DECIMAL(10,2)  DEFAULT 0,
    status           VARCHAR(30)    DEFAULT 'aberta',
    data_vencimento  DATE,
    data_pagamento   DATE,
    PRIMARY KEY (id),
    CONSTRAINT fk_fatura_paciente  FOREIGN KEY (paciente_id) REFERENCES paciente(id),
    CONSTRAINT fk_fatura_convenio  FOREIGN KEY (convenio_id) REFERENCES convenio(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
 
-- ------------------------------------------------------------
-- PAGAMENTO  (depende de fatura)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS pagamento (
    id           INT            NOT NULL AUTO_INCREMENT,
    fatura_id    INT            NOT NULL,
    descricao    VARCHAR(150),
    tipo         VARCHAR(50),
    referencia_id INT,
    quantidade   SMALLINT       DEFAULT 1,
    valor_unit   DECIMAL(10,2)  NOT NULL,
    valor_total  DECIMAL(10,2)  NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_pagamento_fatura  FOREIGN KEY (fatura_id) REFERENCES fatura(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
 
-- ------------------------------------------------------------
-- FUNCIONARIO  (depende de unidade)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS funcionario (
    id            INT          NOT NULL AUTO_INCREMENT,
    unidade_id    INT          NOT NULL,
    nome          VARCHAR(100) NOT NULL,
    cpf           CHAR(11)     NOT NULL UNIQUE,
    cargo         VARCHAR(80),
    departamento  VARCHAR(80),
    telefone      VARCHAR(20),
    email         VARCHAR(100),
    ativo         TINYINT      NOT NULL DEFAULT 1,
    PRIMARY KEY (id),
    CONSTRAINT fk_funcionario_unidade  FOREIGN KEY (unidade_id) REFERENCES unidade(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
 
-- ------------------------------------------------------------
-- NOTIFICACAO  (depende de paciente e funcionario)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS notificacao (
    id              INT          NOT NULL AUTO_INCREMENT,
    paciente_id     INT          NOT NULL,
    funcionario_id  INT,
    tipo            VARCHAR(80),
    canal           VARCHAR(30),
    mensagem        TEXT,
    data_envio      DATETIME     DEFAULT CURRENT_TIMESTAMP,
    status          VARCHAR(30)  DEFAULT 'pendente',
    tentativas      TINYINT      DEFAULT 0,
    PRIMARY KEY (id),
    CONSTRAINT fk_notif_paciente     FOREIGN KEY (paciente_id)    REFERENCES paciente(id),
    CONSTRAINT fk_notif_funcionario  FOREIGN KEY (funcionario_id) REFERENCES funcionario(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
 
-- ------------------------------------------------------------
-- AUDITORIA  (depende de funcionario)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS auditoria (
    id              INT          NOT NULL AUTO_INCREMENT,
    funcionario_id  INT,
    tabela_afetada  VARCHAR(80)  NOT NULL,
    operacao        VARCHAR(20)  NOT NULL,   -- INSERT / UPDATE / DELETE
    registro_id     INT,
    dados_antes     JSON,
    dados_depois    JSON,
    data_hora       DATETIME     DEFAULT CURRENT_TIMESTAMP,
    ip              VARCHAR(45),
    PRIMARY KEY (id),
    CONSTRAINT fk_auditoria_funcionario  FOREIGN KEY (funcionario_id) REFERENCES funcionario(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
 
-- ============================================================
-- PASSO 3 – VERIFICAÇÃO FINAL
-- Liste todas as tabelas para confirmar o resultado
-- ============================================================
 
SHOW TABLES;
 
-- Resultado esperado (20 tabelas):
--  agenda
--  auditoria
--  consulta
--  convenio
--  estoque
--  exame
--  fatura
--  funcionario
--  internacao
--  laboratorio
--  leito
--  medicamento
--  medico
--  notificacao
--  paciente
--  paciente_convenio
--  pagamento
--  prescricao
--  prontuario
--  unidade

USE hospitaldb;
 
-- ============================================================
-- 1. UNIDADE
-- ============================================================
INSERT INTO unidade (nome, tipo, cnpj, telefone, email, endereco, ativa) VALUES
('Hospital MedConnect Central',   'Hospital',  '11.222.333/0001-44', '(11) 3000-1000', 'central@medconnect.com.br',   'Av. Paulista, 1000 – São Paulo/SP',         1),
('Hospital MedConnect Norte',     'Hospital',  '11.222.333/0002-25', '(11) 3000-2000', 'norte@medconnect.com.br',     'R. Voluntários da Pátria, 500 – SP',        1),
('Clínica MedConnect Sul',        'Clinica',   '11.222.333/0003-06', '(11) 3000-3000', 'sul@medconnect.com.br',       'Av. do Estado, 200 – Santo André/SP',       1),
('Clínica MedConnect Leste',      'Clinica',   '11.222.333/0004-97', '(11) 3000-4000', 'leste@medconnect.com.br',     'R. da Consolação, 800 – SP',                1),
('UPA MedConnect Oeste',          'UPA',       '11.222.333/0005-78', '(11) 3000-5000', 'oeste@medconnect.com.br',     'Av. Rebouças, 300 – SP',                    1),
('Hospital MedConnect Campinas',  'Hospital',  '11.222.333/0006-59', '(19) 3100-1000', 'campinas@medconnect.com.br',  'Av. Brasil, 2500 – Campinas/SP',            1),
('Clínica MedConnect Santos',     'Clinica',   '11.222.333/0007-30', '(13) 3200-1000', 'santos@medconnect.com.br',    'R. Brás Cubas, 400 – Santos/SP',            1),
('Hospital MedConnect Ribeirão',  'Hospital',  '11.222.333/0008-10', '(16) 3300-1000', 'ribeirao@medconnect.com.br',  'Av. Costábile Romano, 1500 – Ribeirão/SP',  1),
('Clínica MedConnect ABC',        'Clinica',   '11.222.333/0009-01', '(11) 4000-1000', 'abc@medconnect.com.br',       'Av. Industrial, 600 – São Bernardo/SP',     1),
('UPA MedConnect Sorocaba',       'UPA',       '11.222.333/0010-82', '(15) 3500-1000', 'sorocaba@medconnect.com.br',  'R. XV de Novembro, 900 – Sorocaba/SP',      1);
 
-- ============================================================
-- 2. MEDICO
-- ============================================================
alter table medico
add especialidade VARCHAR(100) NOT NULL;


INSERT INTO medico (nome, crm, especialidade, telefone, email, unidade_id) VALUES
('Dr. Carlos Eduardo Lima',     'CRM-SP 123456', 'Clínica Geral',      '(11) 99100-0001', 'carlos.lima@medconnect.com.br',     1),
('Dra. Fernanda Souza',         'CRM-SP 234567', 'Cardiologia',        '(11) 99100-0002', 'fernanda.souza@medconnect.com.br',  1),
('Dr. Ricardo Alves',           'CRM-SP 345678', 'Ortopedia',          '(11) 99100-0003', 'ricardo.alves@medconnect.com.br',   2),
('Dra. Ana Paula Martins',      'CRM-SP 456789', 'Pediatria',          '(11) 99100-0004', 'ana.martins@medconnect.com.br',     3),
('Dr. Marcos Vinícius Torres',  'CRM-SP 567890', 'Neurologia',         '(11) 99100-0005', 'marcos.torres@medconnect.com.br',   1),
('Dra. Juliana Costa',          'CRM-SP 678901', 'Ginecologia',        '(11) 99100-0006', 'juliana.costa@medconnect.com.br',   4),
('Dr. Paulo Roberto Neves',     'CRM-SP 789012', 'Psiquiatria',        '(11) 99100-0007', 'paulo.neves@medconnect.com.br',     2),
('Dra. Camila Rodrigues',       'CRM-SP 890123', 'Dermatologia',       '(11) 99100-0008', 'camila.rodrigues@medconnect.com.br',5),
('Dr. Eduardo Henrique Dias',   'CRM-SP 901234', 'Endocrinologia',     '(11) 99100-0009', 'eduardo.dias@medconnect.com.br',    6),
('Dra. Patrícia Cunha',         'CRM-SP 012345', 'Infectologia',       '(11) 99100-0010', 'patricia.cunha@medconnect.com.br',  3);
 
-- ============================================================
-- 3. PACIENTE
-- ============================================================
INSERT INTO paciente (nome, cpf, data_nasc, telefone, email, endereco) VALUES

('Maria Oliveira',          '23456789012', '1990-07-22', '(11) 98700-0002', 'maria.oliveira@email.com',   'Av. São João, 55 – SP'),
('Pedro Santos',            '34567890123', '1978-11-30', '(11) 98700-0003', 'pedro.santos@email.com',     'R. Augusta, 200 – SP'),
('Ana Luíza Ferreira',      '45678901234', '2001-01-10', '(11) 98700-0004', 'ana.ferreira@email.com',     'R. Bela Cintra, 80 – SP'),
('Carlos Alberto Rocha',    '56789012345', '1965-09-05', '(11) 98700-0005', 'carlos.rocha@email.com',     'Av. Ipiranga, 340 – SP'),
('Beatriz Lima',            '67890123456', '1998-04-18', '(11) 98700-0006', 'beatriz.lima@email.com',     'R. Haddock Lobo, 15 – SP'),
('Rafael Pereira',          '78901234567', '1993-12-25', '(11) 98700-0007', 'rafael.pereira@email.com',   'R. Oscar Freire, 90 – SP'),
('Luciana Mendes',          '89012345678', '1987-06-08', '(11) 98700-0008', 'luciana.mendes@email.com',   'Av. Rebouças, 500 – SP'),
('Gustavo Almeida',         '90123456789', '2010-02-14', '(11) 98700-0009', 'gustavo.almeida@email.com',  'R. Peixoto Gomide, 30 – SP'),
('Isabela Nascimento',      '01234567890', '1972-08-20', '(11) 98700-0010', 'isabela.nascimento@email.com','R. Pamplona, 120 – SP');
 
-- ============================================================
-- 4. LEITO
-- ============================================================
INSERT INTO leito (unidade_id, numero, tipo, ala, andar, status, obs) VALUES
(1, 'A-101', 'Enfermaria',   'Ala A', 1, 'disponivel',  NULL),
(1, 'A-102', 'Enfermaria',   'Ala A', 1, 'ocupado',     NULL),
(1, 'B-201', 'UTI',          'Ala B', 2, 'disponivel',  'UTI Adulto'),
(1, 'B-202', 'UTI',          'Ala B', 2, 'ocupado',     'UTI Adulto'),
(2, 'C-101', 'Enfermaria',   'Ala C', 1, 'disponivel',  NULL),
(2, 'C-102', 'Particular',   'Ala C', 1, 'disponivel',  'Quarto individual'),
(3, 'D-101', 'Pediátrico',   'Ala D', 1, 'disponivel',  NULL),
(3, 'D-102', 'Pediátrico',   'Ala D', 1, 'ocupado',     NULL),
(6, 'E-201', 'Cirúrgico',    'Ala E', 2, 'disponivel',  'Pós-operatório'),
(6, 'E-202', 'Cirúrgico',    'Ala E', 2, 'manutencao',  'Em manutenção');
 
-- ============================================================
-- 5. CONSULTA
-- ============================================================
SELECT * FROM paciente WHERE id = 10;
SELECT * FROM medico WHERE id = 9;
SELECT * FROM unidade WHERE id = 6;

INSERT INTO paciente (nome, cpf, data_nasc, telefone, email, endereco)
VALUES
('João Silva', '11111111111', '1990-01-01', '(11)99999-1111', 'joao@email.com', 'Rua A'),
('Maria Souza', '22222222222', '1992-02-02', '(11)99999-2222', 'maria@email.com', 'Rua B'),
('Pedro Lima', '33333333333', '1995-03-03', '(11)99999-3333', 'pedro@email.com', 'Rua C');

SELECT id, nome FROM paciente;
SELECT id, nome FROM medico;
SELECT id, nome FROM unidade;

INSERT INTO consulta (paciente_id, medico_id, unidade_id, data_hora, tipo, status, observacoes) VALUES
(1,  1, 1, '2025-05-01 09:00:00', 'Consulta de rotina',    'realizada',  'Paciente em bom estado geral.'),
(22,  2, 1, '2025-05-02 10:30:00', 'Retorno',               'realizada',  'Pressão arterial controlada.'),
(23,  3, 2, '2025-05-05 08:00:00', 'Primeira consulta',     'realizada',  'Queixa de dor no joelho esquerdo.'),
(24,  4, 3, '2025-05-06 14:00:00', 'Consulta pediátrica',   'realizada',  'Criança com febre há 2 dias.'),
(25,  5, 1, '2025-05-07 11:00:00', 'Urgência',              'realizada',  'Cefaleia intensa, encaminhado para TC.'),
(26,  6, 4, '2025-05-08 09:30:00', 'Preventivo',            'realizada',  'Exames preventivos solicitados.'),
(27,  7, 2, '2025-05-09 16:00:00', 'Avaliação psiquiátrica','realizada',  'Iniciado tratamento ambulatorial.'),
(28,  8, 5, '2025-05-10 10:00:00', 'Dermatoscopia',         'realizada',  'Lesão benigna identificada.'),
(29,  1, 1, '2025-05-12 08:30:00', 'Consulta de rotina',    'agendada',   NULL),
(30, 11, 6, '2025-05-13 15:00:00', 'Endocrinologia',        'agendada',   NULL);
 
-- ============================================================
-- 6. INTERNACAO
-- ============================================================

SELECT id FROM leito;

INSERT INTO internacao (paciente_id, medico_id, leito_id, data_entrada, data_saida, diagnostico, status) VALUES
(1, 1, 2, '2025-04-20 08:00:00', '2025-04-25 10:00:00', 'Pneumonia bacteriana',             'alta'),
(22, 2, 4, '2025-05-01 14:00:00', NULL,                   'Insuficiência cardíaca congestiva', 'internado'),
(23, 3, 5, '2025-04-15 10:00:00', '2025-04-18 09:00:00', 'Fratura de tíbia',                 'alta'),
(24, 4, 7, '2025-05-03 11:00:00', NULL,                   'Bronquiolite aguda',               'internado'),
(25, 5, 2, '2025-03-10 09:00:00', '2025-03-15 12:00:00', 'AVC isquêmico leve',               'alta'),
(26, 6, 6, '2025-05-08 16:00:00', NULL,                   'Sangramento uterino',              'internado'),
(27, 7, 1, '2025-04-28 07:00:00', '2025-05-02 08:00:00', 'Surto dissociativo',               'alta'),
(28, 8, 5, '2025-05-05 13:00:00', '2025-05-07 11:00:00', 'Celulite infecciosa',              'alta'),
(29, 1, 3, '2025-05-10 09:00:00', NULL,                   'Sepse em investigação',            'internado'),
(30,9, 9, '2025-05-11 15:00:00', NULL,                   'Pós-operatório de colecistectomia','internado');
 
-- ============================================================
-- 7. PRONTUARIO
-- ============================================================
SELECT id, nome FROM paciente;
INSERT INTO prontuario (paciente_id, medico_id, data_registro, anamnese, diagnostico, evolucao, cid10, ativo) VALUES
(31, 1, '2025-04-20 08:30:00', 'Paciente refere tosse produtiva há 7 dias, febre.',        'Pneumonia bacteriana',             'Iniciado antibiótico. Melhora em 48h.',                              'J18.9', 1),
(22, 2, '2025-05-01 14:30:00', 'Dispneia aos esforços, edema em MMII.',                    'Insuficiência cardíaca congestiva', 'Diurético iniciado. Fração de ejeção 35%.',                          'I50.0', 1),
(23, 3, '2025-04-15 10:30:00', 'Trauma em membro inferior após queda de bicicleta.',       'Fratura de tíbia',                 'Cirurgia de fixação realizada com sucesso.',                          'S82.2', 1),
(24, 4, '2025-05-03 11:30:00', 'Lactente com sibilos e dificuldade respiratória.',         'Bronquiolite aguda',               'Nebulização e hidratação venosa. Melhora gradual.',                   'J21.9', 1),
(25, 5, '2025-03-10 09:30:00', 'Paciente acordou com hemiplegia à esquerda.',              'AVC isquêmico leve',               'Trombolítico administrado. Fisioterapia iniciada.',                   'I63.9', 1),
(26, 6, '2025-05-08 16:30:00', 'Sangramento uterino abundante há 3 dias.',                 'Metrorragia',                      'Ultrassom solicitado. Aguarda resultado para conduta.',               'N93.9', 1),
(27, 7, '2025-04-28 07:30:00', 'Paciente em crise dissociativa após evento estressante.',  'Transtorno dissociativo',          'Estabilizado com benzodiazepínico. Psicoterapia indicada.',           'F44.9', 1),
(28, 8, '2025-05-05 13:30:00', 'Eritema com calor local em perna direita.',                'Celulite infecciosa',              'Antibioticoterapia EV. Melhora em 48h.',                             'L03.1', 1),
(29, 1, '2025-05-10 09:30:00', 'Febre alta, confusão mental, hipotensão.',                 'Sepse em investigação',            'Hemocultura coletada. Antibiótico de largo espectro iniciado.',       'A41.9', 1),
(30,9, '2025-05-11 15:30:00', 'Pós-operatório imediato de colecistectomia laparoscópica.','Pós-op colecistectomia',           'Sem intercorrências. Dieta líquida liberada em 6h.',                  'Z48.0', 1);
 
-- ============================================================
-- 8. MEDICAMENTO
-- ============================================================
INSERT INTO medicamento (nome, principio_ativo, apresentacao, codigo_anvisa, controlado, estoque_minimo) VALUES
('Amoxicilina 500mg',      'Amoxicilina',               '500mg',    'ANVISA-001', 0, 100),
('Dipirona 500mg',         'Dipirona sódica',          '500mg',    'ANVISA-002', 0, 200),
('Omeprazol 20mg',         'Omeprazol',                   '20mg',     'ANVISA-003', 0, 150),
('Rivotril 2mg',           'Clonazepam',               '2mg',      'ANVISA-004', 1,  50),
('Metformina 850mg',       'Metformina',               '850mg',    'ANVISA-005', 0, 100),
('Losartana 50mg',         'Losartana potássica',      '50mg',     'ANVISA-006', 0, 120),
('Insulina NPH 100UI/mL',  'Insulina humana NPH',       '100UI/mL', 'ANVISA-007', 0,  80),
('Ceftriaxona 1g',         'Ceftriaxona sódica',       '1g',       'ANVISA-008', 0,  60),
('Morfina 10mg/mL',        'Sulfato de morfina',       '10mg/mL',  'ANVISA-009', 1,  30),
('Paracetamol 750mg',      'Paracetamol',              '750mg',    'ANVISA-010', 0, 300);
 
-- ============================================================
-- 9. PRESCRICAO
-- ============================================================

SELECT id, nome FROM medicamento;
SELECT id FROM prontuario;
INSERT INTO prescricao (prontuario_id, medico_id, data_prescricao, ativo) VALUES
(1,  1,         '2025-04-20', 1),
(21,  1,         '2025-04-20', 1),
(12,  2,       '2025-05-01', 1),
(13,  3,   '2025-04-15', 0),
(14,  4,  '2025-05-03', 1),
(15,  5,    '2025-03-10', 0),
(16,  6,       '2025-05-08', 1),
(17,  7,     '2025-04-28', 1),
(18,  8,        '2025-05-05', 0),
(19,  1,      '2025-05-10',1);
 
-- ============================================================
-- 10. LABORATORIO
-- ============================================================
SELECT id FROM unidade;
INSERT INTO laboratorio (unidade_id, nome, tipo, responsavel, telefone, email, ativo) VALUES
(1, 'Lab MedConnect Central',  'Análises Clínicas', 'Dr. Fábio Carvalho',    '(11) 3000-1100', 'lab.central@medconnect.com.br',  1),
(2, 'Lab MedConnect Norte',    'Análises Clínicas', 'Dra. Simone Barros',    '(11) 3000-2100', 'lab.norte@medconnect.com.br',    1),
(3, 'Lab MedConnect Sul',      'Microbiologia',     'Dr. Tiago Fonseca',     '(11) 3000-3100', 'lab.sul@medconnect.com.br',      1),
(4, 'Lab MedConnect Leste',    'Análises Clínicas', 'Dra. Luciana Prado',    '(11) 3000-4100', 'lab.leste@medconnect.com.br',    1),
(5, 'Lab MedConnect Oeste',    'Bioquímica',        'Dr. André Santana',     '(11) 3000-5100', 'lab.oeste@medconnect.com.br',    1),
(6, 'Lab MedConnect Campinas', 'Análises Clínicas', 'Dra. Renata Gomes',     '(19) 3100-1100', 'lab.campinas@medconnect.com.br', 1),
(7, 'Lab MedConnect Santos',   'Citologia',         'Dr. Marcelo Vieira',    '(13) 3200-1100', 'lab.santos@medconnect.com.br',   1),
(8, 'Lab MedConnect Ribeirão', 'Análises Clínicas', 'Dra. Cristina Melo',    '(16) 3300-1100', 'lab.ribeirao@medconnect.com.br', 1),
(9, 'Lab MedConnect ABC',      'Hematologia',       'Dr. Hugo Rezende',      '(11) 4000-1100', 'lab.abc@medconnect.com.br',      1),
(10,'Lab MedConnect Sorocaba', 'Análises Clínicas', 'Dra. Priscila Castro',  '(15) 3500-1100', 'lab.sorocaba@medconnect.com.br', 1);
 
-- ============================================================
-- 11. EXAME
-- ============================================================
SELECT id FROM laboratorio;
INSERT INTO laboratorio (id, unidade_id, nome) VALUES 
(1, 1, 'Lab Central'),
(2, 1, 'Lab Diagnóstico'),
(3, 1, 'Lab Santa Luzia'),
(4, 1, 'Lab Imagem'),
(6, 1, 'Lab Bioanálise');
insert into laboratorio (id)
values
(1);
INSERT INTO exame (paciente_id, medico_id, laboratorio_id, tipo, data_solicitacao, resultado, status, urgente) VALUES
(31,  1, 1, 'Hemograma completo',     '2025-04-20', 'Leucocitose 18.000/mm³. Neutrófilos 85%.', 'concluido', 0),
(22,  2, 1, 'Ecocardiograma',         '2025-05-01', 'FE 35%. Disfunção sistólica moderada.',    'concluido', 1),
(23,  3, 2, 'Raio-X tíbia',           '2025-04-15', 'Fratura transversa diáfise tibial.',       'concluido', 1),
(24,  4, 3, 'Painel viral respiratório','2025-05-03','VSR positivo.',                            'concluido', 0),
(25,  5, 1, 'Tomografia de crânio',   '2025-03-10', 'Lesão hipodensa em cápsula interna.',      'concluido', 1),
(26,  6, 4, 'Ultrassom pélvico',      '2025-05-08', 'Aguardando laudo.',                        'pendente',  0),
(27,  7, 2, 'Toxicológico',           '2025-04-28', 'Negativo para substâncias ilícitas.',      'concluido', 0),
(28,  8, 3, 'Cultura de secreção',    '2025-05-05', 'Staphylococcus aureus sensível à oxacilina.','concluido',0),
(29,  1, 1, 'Hemocultura',            '2025-05-10', 'Aguardando resultado em 48h.',             'pendente',  1),
(30, 9, 6, 'Hemograma pós-op',       '2025-05-11', 'Hb 11,2. Sem sinais de hemorragia.',      'concluido', 0);
 
-- ============================================================
-- 12. ESTOQUE
-- ============================================================
INSERT INTO estoque (unidade_id, medicamento_id, quantidade, lote, validade, preco_unit) VALUES
(1, 1, 500,  'LOTE-A001', '2026-06-30', 1.50),
(1, 2, 800,  'LOTE-A002', '2026-08-31', 0.80),
(1, 3, 400,  'LOTE-A003', '2026-12-31', 2.20),
(1, 8, 200,  'LOTE-A004', '2025-12-31', 18.00),
(2, 1, 300,  'LOTE-B001', '2026-06-30', 1.50),
(2, 6, 250,  'LOTE-B002', '2026-10-31', 3.40),
(3, 4, 100,  'LOTE-C001', '2026-04-30', 5.20),
(3, 7,  80,  'LOTE-C002', '2025-11-30', 45.00),
(6, 9,  40,  'LOTE-D001', '2025-10-31', 35.00),
(6,10, 900,  'LOTE-D002', '2026-09-30', 0.60);
 
-- ============================================================
-- 13. AGENDA
-- ============================================================
INSERT INTO agenda (medico_id, unidade_id, data, hora_inicio, hora_fim, status, tipo_consulta, obs) VALUES
(1, 1, '2025-06-02', '08:00', '08:30', 'disponivel',  'Clínica Geral',      NULL),
(1, 1, '2025-06-02', '08:30', '09:00', 'agendado',    'Clínica Geral',      'Paciente João Silva'),
(2, 1, '2025-06-02', '09:00', '09:30', 'agendado',    'Cardiologia',        'Retorno Maria Oliveira'),
(3, 2, '2025-06-03', '08:00', '08:30', 'disponivel',  'Ortopedia',          NULL),
(4, 3, '2025-06-03', '14:00', '14:30', 'agendado',    'Pediatria',          'Consulta Ana Ferreira'),
(5, 1, '2025-06-04', '10:00', '10:30', 'disponivel',  'Neurologia',         NULL),
(6, 4, '2025-06-04', '09:00', '09:30', 'agendado',    'Ginecologia',        'Preventivo Beatriz Lima'),
(7, 2, '2025-06-05', '16:00', '16:30', 'disponivel',  'Psiquiatria',        NULL),
(8, 5, '2025-06-05', '10:00', '10:30', 'cancelado',   'Dermatologia',       'Paciente cancelou'),
(9, 6, '2025-06-06', '15:00', '15:30', 'agendado',    'Endocrinologia',     'Paciente Isabela Nascimento');
 
-- ============================================================
-- 14. CONVENIO
-- ============================================================
INSERT INTO convenio (nome, tipo, ans, telefone, email, cobertura, ativa) VALUES
('Unimed SP',          'Cooperativa',  'ANS-48510', '0800-722-4848', 'unimed@unimedsp.com.br',   'Consultas, internações, exames, cirurgias',    1),
('Amil',               'Seguradora',   'ANS-32300', '0800-722-2645', 'atendimento@amil.com.br',  'Consultas, urgência, internações',             1),
('Bradesco Saúde',     'Seguradora',   'ANS-35000', '0800-722-0870', 'bradescosaude@bradesco.com','Consultas, exames, cirurgias eletivas',         1),
('SulAmérica',         'Seguradora',   'ANS-06246', '4004-2244',     'atendimento@sulamerica.com','Planos completos e modulares',                 1),
('Hapvida',            'Cooperativa',  'ANS-36166', '0800-722-0101', 'atendimento@hapvida.com.br','Rede própria hospitais e clínicas',            1),
('NotreDame Intermédica','Seguradora', 'ANS-35182', '4004-1312',     'sac@intermedica.com.br',   'Consultas, internações, exames',               1),
('Prevent Senior',     'Filantrópica', 'ANS-41256', '0800-772-7473', 'sac@preventsenior.com.br', 'Foco em pacientes acima de 50 anos',           1),
('Golden Cross',       'Seguradora',   'ANS-12670', '0800-701-4554', 'sac@goldencross.com.br',   'Consultas, exames básicos e urgência',         1),
('Porto Seguro Saúde', 'Seguradora',   'ANS-20010', '4003-7420',     'saude@portoseguro.com.br', 'Planos individual, familiar e empresarial',    1),
('Particular',         'Particular',   NULL,        NULL,            NULL,                        'Pagamento particular sem cobertura de plano', 1);
 
-- ============================================================
-- 15. PACIENTE_CONVENIO
-- ============================================================

INSERT INTO paciente_convenio (paciente_id, convenio_id, numero_carteirinha, plano, data_inicio, data_fim, titular, ativa) VALUES
(31,  1, 'UNI-00123456', 'Unimed Flex Plus',    '2020-01-01', NULL,         1, 1),
(22,  2, 'AMI-00234567', 'Amil 400',            '2019-06-01', NULL,         1, 1),
(23,  3, 'BRA-00345678', 'Bradesco Nacional',   '2021-03-01', NULL,         1, 1),
(24,  4, 'SUL-00456789', 'SulAmérica Especial', '2022-07-01', NULL,         1, 1),
(25,  5, 'HAP-00567890', 'Hapvida Master',      '2018-01-01', '2025-01-01', 1, 0),
(26,  6, 'NOT-00678901', 'Intermédica Gold',    '2023-01-01', NULL,         1, 1),
(27,  7, 'PRE-00789012', 'Prevent 60+',         '2020-05-01', NULL,         1, 1),
(28,  8, 'GOL-00890123', 'Golden Cross Basic',  '2021-09-01', NULL,         1, 1),
(29,  1, 'UNI-00901234', 'Unimed Básico',       '2024-01-01', NULL,         0, 1),
(30,10, NULL,           'Particular',          '2025-01-01', NULL,         1, 1);
 
-- ============================================================
-- 16. FATURA
-- ============================================================
INSERT INTO fatura (paciente_id, convenio_id, data_emissao, valor_total, desconto, status, data_vencimento, data_pagamento) VALUES
(31, 1,  '2025-04-25', 3500.00,  500.00, 'paga',     '2025-05-10', '2025-05-08'),
(22, 2,  '2025-05-10', 8200.00, 1200.00, 'aberta',   '2025-05-25', NULL),
(23, 3,  '2025-04-18', 6100.00,  800.00, 'paga',     '2025-05-05', '2025-05-03'),
(24, 4,  '2025-05-15', 2800.00,  300.00, 'aberta',   '2025-05-30', NULL),
(25, 5,  '2025-03-15', 4500.00,    0.00, 'paga',     '2025-04-01', '2025-03-30'),
(26, 6,  '2025-05-20', 3200.00,  200.00, 'aberta',   '2025-06-05', NULL),
(27, 7,  '2025-05-02', 5600.00,  600.00, 'paga',     '2025-05-17', '2025-05-15'),
(28, 8,  '2025-05-07', 1900.00,    0.00, 'paga',     '2025-05-22', '2025-05-20'),
(29, 1,  '2025-05-20', 9800.00, 1000.00, 'aberta',   '2025-06-05', NULL),
(30,10, '2025-05-15', 4200.00,    0.00, 'aberta',   '2025-05-30', NULL);
 
-- ============================================================
-- 17. PAGAMENTO
-- ============================================================
SELECT id FROM fatura;
INSERT INTO pagamento (fatura_id, descricao, tipo, referencia_id, quantidade, valor_unit, valor_total) VALUES
(20, 'Diária de internação',    'internacao',  1, 5,  500.00, 2500.00),
(11, 'Antibiótico EV',          'medicamento', 1, 3,   45.00,  135.00),
(12, 'Diária UTI',              'internacao',  2, 8,  900.00, 7200.00),
(13, 'Cirurgia ortopédica',     'cirurgia',    3, 1, 4800.00, 4800.00),
(13, 'Raio-X',                  'exame',       3, 1,  180.00,  180.00),
(14, 'Diária pediátrica',       'internacao',  4, 4,  600.00, 2400.00),
(15, 'Diária AVC',              'internacao',  5, 5,  700.00, 3500.00),
(17, 'Internação psiquiátrica', 'internacao',  7, 4,  950.00, 3800.00),
(18, 'Consulta dermatológica',  'consulta',    8, 1,  350.00,  350.00),
(18, 'Exame microbiológico',    'exame',       8, 1,  280.00,  280.00);
 
-- ============================================================
-- 18. FUNCIONARIO
-- ============================================================
INSERT INTO funcionario (unidade_id, nome, cpf, cargo, departamento, telefone, email, ativo) VALUES
(1, 'Roberta Alves',        '11122233344', 'Enfermeira',          'Enfermagem',       '(11) 97700-0001', 'roberta.alves@medconnect.com.br',    1),
(1, 'Diego Mendonça',       '22233344455', 'Técnico de Farmácia', 'Farmácia',         '(11) 97700-0002', 'diego.mendonca@medconnect.com.br',   1),
(1, 'Tatiane Ribeiro',      '33344455566', 'Recepcionista',       'Administrativo',   '(11) 97700-0003', 'tatiane.ribeiro@medconnect.com.br',  1),
(2, 'Fábio Cardoso',        '44455566677', 'Enfermeiro',          'Enfermagem',       '(11) 97700-0004', 'fabio.cardoso@medconnect.com.br',    1),
(3, 'Silvia Teixeira',      '55566677788', 'Técnica de Enfermagem','Enfermagem',      '(11) 97700-0005', 'silvia.teixeira@medconnect.com.br',  1),
(4, 'Leandro Castro',       '66677788899', 'Auxiliar Adm.',       'Administrativo',   '(11) 97700-0006', 'leandro.castro@medconnect.com.br',   1),
(5, 'Patrícia Lopes',       '77788899900', 'Farmacêutica',        'Farmácia',         '(11) 97700-0007', 'patricia.lopes@medconnect.com.br',   1),
(6, 'Rodrigo Fernandes',    '88899900011', 'Enfermeiro',          'Enfermagem',       '(19) 97700-0008', 'rodrigo.fernandes@medconnect.com.br',1),
(1, 'Cintia Moraes',        '99900011122', 'Gerente de TI',       'Tecnologia',       '(11) 97700-0009', 'cintia.moraes@medconnect.com.br',    1),
(1, 'Bruno Lacerda',        '00011122233', 'Analista de Dados',   'Tecnologia',       '(11) 97700-0010', 'bruno.lacerda@medconnect.com.br',    1);
 
-- ============================================================
-- 19. NOTIFICACAO
-- ============================================================
INSERT INTO notificacao (paciente_id, funcionario_id, tipo, canal, mensagem, data_envio, status, tentativas) VALUES
(31, 3, 'Confirmação de consulta', 'SMS',   'Sua consulta está confirmada para 01/05 às 09h.',         '2025-04-30 18:00:00', 'enviado',  1),
(22, 3, 'Resultado de exame',      'Email', 'Seu exame de ecocardiograma está disponível.',             '2025-05-03 10:00:00', 'enviado',  1),
(23, 4, 'Alta hospitalar',         'SMS',   'Você recebeu alta. Retorne em 7 dias para revisão.',       '2025-04-18 09:30:00', 'enviado',  1),
(24, 5, 'Lembrete de medicação',   'SMS',   'Não esqueça do medicamento às 20h.',                       '2025-05-04 19:00:00', 'enviado',  1),
(25, 3, 'Agendamento fisioterapia','Email', 'Sessão de fisioterapia agendada para 17/03 às 10h.',       '2025-03-16 09:00:00', 'enviado',  1),
(26, 6, 'Resultado pendente',      'Email', 'Resultado do ultrassom disponível em breve.',              '2025-05-09 08:00:00', 'pendente', 0),
(27, 4, 'Retorno psiquiátrico',    'SMS',   'Lembrete: consulta de retorno em 10/05 às 16h.',          '2025-05-09 10:00:00', 'enviado',  1),
(28, 5, 'Alta hospitalar',         'SMS',   'Alta confirmada. Continue antibiótico por mais 5 dias.',  '2025-05-07 11:30:00', 'enviado',  1),
(29, 3, 'Exame crítico',           'Email', 'Resultado de hemocultura disponível. Verificar urgente.',  '2025-05-11 08:00:00', 'pendente', 2),
(30,3, 'Alta pós-operatória',     'SMS',   'Parabéns pela cirurgia! Retorne em 7 dias para revisão.', '2025-05-12 09:00:00', 'pendente', 0);
 
-- ============================================================
-- 20. AUDITORIA
-- ============================================================
INSERT INTO auditoria (funcionario_id, tabela_afetada, operacao, registro_id, dados_antes, dados_depois, data_hora, ip) VALUES
(9,  'paciente',    'INSERT', 10, NULL,
     '{"nome":"Isabela Nascimento","cpf":"01234567890"}',
     '2025-01-15 09:00:00', '192.168.1.10'),
(9,  'medico',      'INSERT',  1, NULL,
     '{"nome":"Dr. Carlos Eduardo Lima","crm":"CRM-SP 123456"}',
     '2025-01-15 09:05:00', '192.168.1.10'),
(10, 'internacao',  'UPDATE',  2,
     '{"status":"internado","leito_id":4}',
     '{"status":"internado","leito_id":3}',
     '2025-05-02 14:00:00', '192.168.1.15'),
(3,  'consulta',    'INSERT',  9, NULL,
     '{"paciente_id":9,"medico_id":1,"data_hora":"2025-05-12 08:30:00"}',
     '2025-05-10 10:00:00', '192.168.1.12'),
(3,  'fatura',      'UPDATE',  1,
     '{"status":"aberta"}',
     '{"status":"paga","data_pagamento":"2025-05-08"}',
     '2025-05-08 16:00:00', '192.168.1.12'),
(9,  'estoque',     'UPDATE',  1,
     '{"quantidade":600}',
     '{"quantidade":500}',
     '2025-05-01 08:00:00', '192.168.1.10'),
(10, 'prescricao',  'INSERT', 10, NULL,
     '{"prontuario_id":9,"medicamento_id":8,"dosagem":"2g"}',
     '2025-05-10 09:45:00', '192.168.1.15'),
(9,  'leito',       'UPDATE', 10,
     '{"status":"disponivel"}',
     '{"status":"manutencao"}',
     '2025-05-09 07:30:00', '192.168.1.10'),
(3,  'agenda',      'UPDATE',  9,
     '{"status":"disponivel"}',
     '{"status":"cancelado"}',
     '2025-05-04 11:00:00', '192.168.1.12'),
(10, 'unidade',     'INSERT',  1, NULL,
     '{"nome":"Hospital MedConnect Central","cnpj":"11.222.333/0001-44"}',
     '2025-01-10 08:00:00', '192.168.1.15');
 
-- ============================================================
-- VERIFICAÇÃO FINAL – conte os registros por tabela
-- ============================================================
SELECT 'unidade'          AS tabela, COUNT(*) AS registros FROM unidade          UNION ALL
SELECT 'medico',                     COUNT(*)              FROM medico            UNION ALL
SELECT 'paciente',                   COUNT(*)              FROM paciente          UNION ALL
SELECT 'leito',                      COUNT(*)              FROM leito             UNION ALL
SELECT 'consulta',                   COUNT(*)              FROM consulta          UNION ALL
SELECT 'internacao',                 COUNT(*)              FROM internacao        UNION ALL
SELECT 'prontuario',                 COUNT(*)              FROM prontuario        UNION ALL
SELECT 'medicamento',                COUNT(*)              FROM medicamento       UNION ALL
SELECT 'prescricao',                 COUNT(*)              FROM prescricao        UNION ALL
SELECT 'laboratorio',                COUNT(*)              FROM laboratorio       UNION ALL
SELECT 'exame',                      COUNT(*)              FROM exame             UNION ALL
SELECT 'estoque',                    COUNT(*)              FROM estoque           UNION ALL
SELECT 'agenda',                     COUNT(*)              FROM agenda            UNION ALL
SELECT 'convenio',                   COUNT(*)              FROM convenio          UNION ALL
SELECT 'paciente_convenio',          COUNT(*)              FROM paciente_convenio UNION ALL
SELECT 'fatura',                     COUNT(*)              FROM fatura            UNION ALL
SELECT 'pagamento',                  COUNT(*)              FROM pagamento         UNION ALL
SELECT 'funcionario',                COUNT(*)              FROM funcionario       UNION ALL
SELECT 'notificacao',                COUNT(*)              FROM notificacao       UNION ALL
SELECT 'auditoria',                  COUNT(*)              FROM auditoria;