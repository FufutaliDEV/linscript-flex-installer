#!/bin/bash
# NOME DO ARQUIVO: Linscript-Instalador-Flex-Shell.sh
# FUNÇÃO: Instala a interface Zenity (Gráfica) ou Shell (Terminal) do Linscript, 
#         usando uma interface de terminal pura para a escolha.

# --- 1. CONFIGURAÇÃO DOS LINKS RAW ---

# [CONFIRMADO] Link RAW para a Versão Gráfica (Zenity)
URL_ZENITY="https://gist.githubusercontent.com/FufutaliDEV/158dcea3cef6d6e375f48eb815b9660c/raw/8f915a802c35230336e30078df09431b601096ce/linscriptzenity.sh"

# [PENDENTE - Substitua esta linha] Link RAW para a Versão Terminal (Shell Pura)
URL_SHELL="https://gist.githubusercontent.com/FufutaliDEV/a3f0644994e39d78a9e9c40e5b788e24/raw/31288c9a54e1fafc3f95c6c2a1629e0f5f1c0401/linscriptshell.sh" 

# Configurações locais
SCRIPT_NOME="linscript-main.sh"
LOCAL_SCRIPT="$HOME/.local/linscript-app/$SCRIPT_NOME"
LOCAL_DIRETORIO="$HOME/.local/linscript-app"
ARQUIVO_DESKTOP="$HOME/.local/share/applications/ferramentas.desktop"

# --- 2. FUNÇÕES DE INFRAESTRUTURA ---

instalar_dependencias_iniciais() {
    # Garante que o Curl esteja instalado para o download
    if ! command -v curl &> /dev/null
    then
        echo "Curl não encontrado. Instalando..."
        sudo apt update > /dev/null 2>&1
        sudo apt install curl -y
        
        if [ $? -ne 0 ]; then
            echo "ERRO: Falha ao instalar Curl. Abortando."
            exit 1
        fi
    fi
}

escolher_edicao() {
    echo "========================================================"
    echo "  ESCOLHA A EDIÇÃO DO LINSCRIPT"
    echo "========================================================"
    echo "1. ZENITY (Gráfica): Interface amigável (Requer Zenity para rodar)."
    echo "2. SHELL (Terminal Puro): Leve e otimizado para Debian (APT)."
    echo "--------------------------------------------------------"
    
    # Faz a pergunta no terminal (Shell)
    read -p "Selecione a opção (1 ou 2) ou 'c' para cancelar: " ESCOLHA_NUMERICA

    case "$ESCOLHA_NUMERICA" in
        1)
            SCRIPT_URL=$URL_ZENITY
            NOME_APP="Ferramentas (Gráficas Zenity)"
            ESCOLHA="ZENITY"
            # Instala Zenity se o usuário o escolheu
            echo "Instalando Zenity para a edição Gráfica..."
            sudo apt install zenity -y
            ;;
        2)
            SCRIPT_URL=$URL_SHELL
            NOME_APP="Ferramentas (Terminal Puro)"
            ESCOLHA="SHELL"
            ;;
        c|C|C)
            echo "Instalação cancelada pelo usuário."
            exit 0
            ;;
        *)
            echo "Opção inválida. Reinicie o script e tente novamente."
            exit 1
            ;;
    esac
}

baixar_script() {
    echo "Baixando a versão '$NOME_APP' (via GitHub) da URL: $SCRIPT_URL"
    
    # O Comando CURL para baixar o arquivo do link RAW
    curl -sLf "$SCRIPT_URL" -o "$LOCAL_SCRIPT"
    DOWNLOAD_STATUS=$?
    
    if [ $DOWNLOAD_STATUS -ne 0 ]; then
        echo "ERRO CRÍTICO (Download): Falha ao baixar o script. Verifique se o link RAW é válido."
        echo "Status da falha do CURL: $DOWNLOAD_STATUS"
        exit 1
    fi
    
    chmod +x "$LOCAL_SCRIPT"
    echo "Download concluído e permissões definidas."
}

instalar_atalho() {
    echo "Criando atalho .desktop (para menu de aplicativos)..."
    DESKTOP_ENTRY="[Desktop Entry]\n"
    DESKTOP_ENTRY+="Name=$NOME_APP\n"
    DESKTOP_ENTRY+="Comment=Ferramentas de Manutenção Linux simplificadas. Edição: $NOME_APP.\n"
    DESKTOP_ENTRY+="Exec=bash \"$LOCAL_SCRIPT\"\n" 
    
    # O atalho deve abrir um terminal se for a versão SHELL
    [[ "$ESCOLHA" == "SHELL" ]] && DESKTOP_ENTRY+="Terminal=true\n" || DESKTOP_ENTRY+="Terminal=false\n"
    
    DESKTOP_ENTRY+="Type=Application\n"
    DESKTOP_ENTRY+="Icon=utilities-system-monitor\n"
    DESKTOP_ENTRY+="Categories=System;Utility;\n"

    mkdir -p "$HOME/.local/share/applications"
    echo -e "$DESKTOP_ENTRY" > "$ARQUIVO_DESKTOP"
    chmod +x "$ARQUIVO_DESKTOP"
    
    echo "✅ Instalação Concluída! O atalho '$NOME_APP' foi criado."
}

# --- 3. EXECUÇÃO PRINCIPAL ---
echo "========================================================"
echo "  INICIANDO INSTALADOR FLEXÍVEL LINSCRIPT (TERMINAL)"
echo "========================================================"

instalar_dependencias_iniciais

escolher_edicao

if [ "$ESCOLHA" == "ZENITY" ] || [ "$ESCOLHA" == "SHELL" ]; then
    baixar_script        
    instalar_atalho      
    
    echo "Abrindo o menu principal..."
    "$LOCAL_SCRIPT"
fi

exit 0
