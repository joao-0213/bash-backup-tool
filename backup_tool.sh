#!/bin/bash

# Ferramenta de Backup com Rsync e Cron
# Este script fornece um menu interativo para realizar e agendar backups usando rsync.

# Função para exibir o menu, coletar e executaar as opções do usuário
menu() {
    clear
    echo "==== Ferramenta de Backup ===="
    echo "Escolha uma opção:"
    echo "1. Realizar backup agora"
    echo "2. Agendamento de backup"
    echo "3. Sair"
    
    # Lê a opção do usuário e executa as funções correspondentes
    read -r opcao

    case $opcao in
        1)  dir_select
            perform_backup
            ;;
        2)  dir_select
            create_schedule
            ;;
        3)  echo "Saindo..."
            exit
            ;;
        *)  echo "Opção inválida!"
            ;;
    esac
    read -r -s -p $'\nPressione ENTER para continuar.'
}

# Função para seleção dos diretórios de origem e destino do backup
dir_select() {
    local response
    local dirs
    # Executa até que o usuário confirme a seleção do diretório com 'yes' ou 'y'
    while [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; do
        clear
        echo 'Escolha o(s) diretório(s) de origem...'
        sleep 1
        dirs=$(zenity --file-selection --multiple --directory --title='Escolha o(s) diretório(s) de origem')
        if [ -z "$dirs" ]; then
    	    menu
        fi
        # Divide os diretórios selecionados em um array usando '|' como delimitador
        IFS='|' read -r -a srcdir <<< "$dirs"
        echo "Você selecionou: ${srcdir[*]}"
        for i in "${!srcdir[@]}"; do
        # Prepara os caminhos dos diretórios de origem para uso da opção de caminho relativo do rsync
            srcdir[i]="${srcdir[i]%/*}/./${srcdir[i]##*/}"
        done

        echo $'\nEscolha o diretório de DESTINO...'
        sleep 2
        destdir=$(zenity --file-selection --directory --title="Escolha o diretório de destino")
        if [ -z "$destdir" ]; then
    	    menu
        fi
        echo "Você selecionou: $destdir"
        read -r -p $'\nConfirma a seleção? [y/N] ' response
    done
}

# Função de execução do rsync para realizar backup
perform_backup() {
    logfile="backup_log$(date +%Y%m%d_%H%M%S).txt"
    rsync -ahuvR --info=progress2 --log-file=$logfile --delete ${srcdir[*]}/ $destdir/
    printf "\nO backup foi finalizado. Um arquivo de log foi gerado: $(pwd)/$logfile"
}

# Função que solicita os argumentos de intervalo de execução e cria o script que será executado regularmente pela tarefa cron criada
create_schedule() {
    clear
    
    # Solicita ao usuário que insira os parâmetros de agendamento do cron
    echo $'Configure o tempo em que deseja realizar o backup.\n'
    read -r -p "Digite o minuto (0-59) ou '*' para todo minuto: " minute
    read -r -p "Digite a hora (0-23) ou '*' para toda hora: " hour
    read -r -p "Digite o dia do mês (1-31) ou '*' para todo dia: " day_of_month
    read -r -p "Digite o mês (1-12) ou '*' para todo mês: " month
    read -r -p "Digite o dia da semana (0-7 onde ambos 0 e 7 representam Domingo) ou '*' para todos os dias da semana: " day_of_week
    
    echo $'\nEscolha o local para armazenar o log e o script do backup...'
    sleep 1
    tooldir=$(zenity --file-selection --directory --title="Escolha o local para armazenar logs e o script do backup")
    if [ -z "$destdir" ]; then
    	menu
    fi
    echo "Você selecionou: $tooldir"
    read -r -p $'\nPor fim, digite um nome para essa tarefa de backup: ' name
    
    # Cria um novo script bash para execução do backup na tarefa cron
    cat >"${tooldir}/${name}backup_schedule.sh" <<EOF
#!/bin/bash
rsync -ahuvR --info=progress2 --log-file=${tooldir}/${name}log.txt --exclude={'${name}backup_schedule.sh','${name}backup_log.txt','${name}log.txt'} --delete ${srcdir[*]}/ $destdir/
cat ${tooldir}/${name}log.txt >> ${tooldir}/${name}backup_log.txt
echo "-------------------------------------------" >> ${tooldir}/${name}backup_log.txt
rm ${tooldir}/${name}log.txt
EOF

    chmod +x ${tooldir}/${name}backup_schedule.sh
    
    # Adiciona o novo script ao crontab para execução regular de acordo com o cronograma especificado pelo usuário
    (crontab -l 2>/dev/null; echo "$minute $hour $day_of_month $month $day_of_week ${tooldir}/${name}backup_schedule.sh") | crontab -
    
    echo "Tarefa de backup criada. O arquivo de log será armazenado no seguinte endereço: ${tooldir}/${name}backup_log.txt"
}

# Loop principal do script que continua exibindo o menu até que a opção "sair" seja escolhida
while true; do
    menu
done
