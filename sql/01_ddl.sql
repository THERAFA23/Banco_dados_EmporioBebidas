


CREATE TABLE categoria (
    id_categoria SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL
);

CREATE TABLE produto (
    id_produto SERIAL PRIMARY KEY,
    id_categoria INT NOT NULL,
    nome VARCHAR(150) NOT NULL,
    preco DECIMAL(10, 2) NOT NULL,
    quantidade_estoque INT NOT NULL DEFAULT 0,
    FOREIGN KEY (id_categoria) REFERENCES categoria(id_categoria)
);

-- Especificação (Entidade Fraca de Produto - Relação 1:1)
CREATE TABLE especificacao (
    id_produto INT PRIMARY KEY,
    codigo_interno VARCHAR(50),
    pais_origem VARCHAR(50),
    teor_alcoolico DECIMAL(5, 2),
    volume VARCHAR(20),
    FOREIGN KEY (id_produto) REFERENCES produto(id_produto) ON DELETE CASCADE
);

CREATE TABLE cliente (
    id_cliente SERIAL PRIMARY KEY,
    cpf VARCHAR(11) UNIQUE NOT NULL,
    nome VARCHAR(150) NOT NULL,
    data_nascimento DATE NOT NULL
);

-- Telefone (Atributo Multivalorado de Cliente)
CREATE TABLE cliente_telefone (
    id_cliente INT NOT NULL,
    numero_telefone VARCHAR(20) NOT NULL,
    PRIMARY KEY (id_cliente, numero_telefone),
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente) ON DELETE CASCADE
);

CREATE TABLE endereco (
    id_endereco SERIAL PRIMARY KEY,
    id_cliente INT NOT NULL,
    cep VARCHAR(10) NOT NULL,
    bairro VARCHAR(100) NOT NULL,
    rua VARCHAR(150) NOT NULL,
    numero VARCHAR(10) NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente) ON DELETE CASCADE
);

-- Venda (Agrupa Entrega e Retirada)
CREATE TABLE venda (
    id_venda SERIAL PRIMARY KEY,
    id_cliente INT NOT NULL,
    data_venda DATE NOT NULL,
    horario_venda TIME NOT NULL,
    valor_total DECIMAL(10, 2) NOT NULL,
    tipo VARCHAR(20) NOT NULL CHECK (tipo IN ('Entrega', 'Retirada')),
    valor_frete DECIMAL(10, 2), -- Preenchido apenas se tipo = 'Entrega'
    numero_retirada INT,        -- Preenchido apenas se tipo = 'Retirada'
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente)
);

-- Item_Pedido (Entidade Fraca de Venda)
CREATE TABLE item_pedido (
    id_venda INT NOT NULL,
    item_venda INT NOT NULL, -- Identificador parcial (ex: Item 1, Item 2 da mesma venda)
    id_produto INT NOT NULL,
    quantidade INT NOT NULL,
    preco_unitario DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (id_venda, item_venda),
    FOREIGN KEY (id_venda) REFERENCES venda(id_venda) ON DELETE CASCADE,
    FOREIGN KEY (id_produto) REFERENCES produto(id_produto)
);