# 🏥 MedConnect — Modelagem de Dados Unificada para Redes Hospitalares

> **Trabalho de Modelagem de Banco de Dados**  
> Aluno: **José Eduardo de Souza Pereira** · RA: `220100`  
> Instituição: UNASP – Centro Universitário Adventista de São Paulo  
> Curso: Engenharia da Computação

---

## 📋 Sobre o Projeto

A **MedConnect** é uma rede fictícia de hospitais e clínicas privadas criada para ilustrar um problema real do setor de saúde: a **fragmentação de dados clínicos e operacionais**.

Cada unidade hospitalar operava com sistemas legados independentes — cadastros duplicados de pacientes, históricos médicos em papel, agendamentos sem integração com farmácia e estoque. O resultado era demora no atendimento, erros de medicação, perda de receita por leitos ociosos e relatórios gerenciais não confiáveis.

A solução proposta é um **modelo de dados relacional unificado com 20 tabelas**, cobrindo todas as áreas críticas da rede hospitalar.

---

## 🗂️ Estrutura do Repositório
medconnect-db/
│
├── 📊 MedMedico_DIAGRAMA.xml          # Diagrama DER editável (draw.io)
├── 🗄️ corrigir_hospitaldb.sql         # Script de criação/correção das tabelas
├── 📥 inserir_dados_hospitaldb.sql    # Script de inserção de dados (200 registros)
└── 📽️ MedConnect_Apresentacao.pptx   # Slides da apresentação

---

## 🗃️ Diagrama Entidade-Relacionamento (DER)

> Abra o arquivo `MedMedico_DIAGRAMA.xml` no [draw.io](https://draw.io) para visualizar e editar o diagrama completo.

![Diagrama DER – MedConnect](diagrama_der.png)

---

## 🏗️ Tabelas do Banco de Dados

O banco `hospitaldb` é composto por **20 tabelas relacionais**, organizadas em 5 módulos:

### 👤 Pacientes & Profissionais
| Tabela | Descrição |
|---|---|
| `paciente` | Cadastro unificado de pacientes |
| `medico` | Médicos e suas especialidades |
| `funcionario` | Equipe administrativa e de enfermagem |

### 🏨 Atendimento
| Tabela | Descrição |
|---|---|
| `unidade` | Hospitais, clínicas e UPAs da rede |
| `leito` | Controle de leitos por unidade |
| `agenda` | Horários disponíveis e agendamentos |
| `consulta` | Registro de consultas realizadas |
| `internacao` | Admissões, leitos e altas hospitalares |
| `prontuario` | Histórico médico eletrônico com CID-10 |

### 💊 Farmácia
| Tabela | Descrição |
|---|---|
| `medicamento` | Catálogo de medicamentos com código ANVISA |
| `prescricao` | Prescrições médicas vinculadas ao prontuário |
| `estoque` | Controle de estoque por unidade, lote e validade |

### 🔬 Exames & Infraestrutura
| Tabela | Descrição |
|---|---|
| `laboratorio` | Laboratórios de cada unidade |
| `exame` | Solicitações e resultados de exames |

### 💰 Faturamento & Convênios
| Tabela | Descrição |
|---|---|
| `convenio` | Convênios médicos credenciados |
| `paciente_convenio` | Vínculo paciente ↔ convênio com carteirinha |
| `fatura` | Faturas por atendimento |
| `pagamento` | Itens e valores de cada fatura |

### 🔔 Governança
| Tabela | Descrição |
|---|---|
| `notificacao` | Notificações por SMS e e-mail aos pacientes |
| `auditoria` | Log de todas as operações no banco |

---

## ⚙️ Como Executar

### Pré-requisitos
- MySQL 8.0+ (ou MariaDB 10.6+)
- MySQL Workbench (recomendado) ou outro client SQL

### Passo a passo

**1. Crie o banco de dados**
```sql
CREATE DATABASE IF NOT EXISTS hospitaldb
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
```

**2. Execute o script de correção/criação das tabelas**
```bash
mysql -u root -p hospitaldb < corrigir_hospitaldb.sql
```
Ou abra o arquivo `corrigir_hospitaldb.sql` no Workbench e execute.

**3. Insira os dados de exemplo**
```bash
mysql -u root -p hospitaldb < inserir_dados_hospitaldb.sql
```

**4. Verifique o resultado**
```sql
USE hospitaldb;
SHOW TABLES;
-- Deve retornar as 20 tabelas
```

---

## 📊 Dados de Exemplo

Cada tabela contém **10 registros** de exemplo, totalizando **200 registros** no banco.

| Dado | Quantidade |
|---|---|
| Unidades hospitalares | 10 |
| Médicos cadastrados | 10 |
| Pacientes | 10 |
| Consultas | 10 |
| Internações | 10 |
| Prontuários | 10 |
| Medicamentos | 10 |
| Exames | 10 |
| Convênios | 10 |
| Registros de auditoria | 10 |

---

## 🎯 Decisões de Projeto

- **Normalização até 3ª Forma Normal (3FN)** — elimina redundâncias e dependências transitivas
- **Chaves primárias sintéticas** (`AUTO_INCREMENT`) em todas as tabelas
- **Integridade referencial** via `FOREIGN KEY` com `ON DELETE RESTRICT`
- **Campos de auditoria** — `created_at` / `updated_at` nas tabelas principais
- **Índices** nas colunas de alta frequência de busca (CPF, CRM, datas)
- **Dados sensíveis** — CPF e CRM armazenados como `CHAR` para busca exata
- **Engine InnoDB** em todas as tabelas para suporte a transações e FKs

---

## 🛠️ Tecnologias Utilizadas

![MySQL](https://img.shields.io/badge/MySQL-8.0-4479A1?style=flat&logo=mysql&logoColor=white)
![draw.io](https://img.shields.io/badge/draw.io-DER-F08705?style=flat&logo=diagrams.net&logoColor=white)
![PowerPoint](https://img.shields.io/badge/PowerPoint-Apresentação-B7472A?style=flat&logo=microsoft-powerpoint&logoColor=white)

---

## 👨‍💻 Autor

**José Eduardo de Souza Pereira**  
