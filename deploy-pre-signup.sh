#!/bin/bash


LAMBDA_FUNCTION_NAME="LambdaPreSignUp"


LAMBDA_DIR=./lambda-pre-signup

# Nome do arquivo ZIP que contém o código Python
ZIP_FILE="lambda_pre_signup.zip"

# Nome do diretório temporário para empacotamento
TEMP_DIR="lambda_temp"

# Cria um diretório temporário para empacotamento
if [ -d $TEMP_DIR ]; then
    echo "Removendo diretório temporário existente..."
    rm -rf $TEMP_DIR
fi

if [ -d $ZIP_FILE ]; then
    echo "Removendo antigo pacote da lambda existente"
    rm -rf $ZIP_FILE
fi

echo "Criando diretório temporário..."
mkdir $TEMP_DIR

# Copia todos os arquivos necessários para o diretório temporário
echo "Copiando arquivos para o diretório temporário..."
cp -r $LAMBDA_DIR/* $TEMP_DIR

# Instala as dependências no diretório temporário
echo "Instalando dependências no diretório temporário..."
pip install -r $TEMP_DIR/requirements.txt -t $TEMP_DIR

# Cria o arquivo ZIP com todos os arquivos no diretório temporário
echo "Criando arquivo ZIP com o código Python..."
cd $TEMP_DIR
zip -r ../$ZIP_FILE .
cd ..

# Remove o diretório temporário
echo "Removendo diretório temporário..."
rm -rf $TEMP_DIR

# Atualiza a função Lambda existente
aws lambda update-function-code \
    --function-name $LAMBDA_FUNCTION_NAME \
    --zip-file fileb://$ZIP_FILE

echo "Função Lambda atualizada com sucesso!"
