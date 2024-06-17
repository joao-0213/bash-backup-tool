
# Ferramenta de Backup com Rsync e Cron

## Descrição
Este script de shell foi desenvolvido como parte do projeto final da disciplina DS010 - Administração de Sistemas, do curso de Análise e Desenvolvimento de Sistemas, da Universidade Federal do Paraná (UFPR), ministrada pelo Prof. Dr. Mauro Antônio Alves Castro. Utilizando o comando `rsync`, o script oferece uma interface interativa para realizar backups imediatos ou agendados através do `cron`, de forma facilitada.

## Funcionalidades
- **Backup Imediato**: Permite ao usuário a realização de um backup a qualquer momento.
- **Agendamento de Backup**: Possibilita a configuração do `cron` para realizar backups em intervalos regulares.
- **Seleção de Diretórios**: Escolha quais pastas deseja salvar e onde será feito o backup usando a janela GUI de seleção de arquivos do `zenity`.
- **Interface Interativa**: Possui um menu simples para navegar pelas opções do script.
- **Logs de Backup**: Mantém registros de cada backup realizado.

## Requisitos
- `rsync`para a execução da sincronização dos diretórios.
- `cron` para o agendamento dos backups.
- `zenity` para a seleção de diretórios através da interface gráfica.

## Uso
1. Abra um terminal no diretório onde o script está localizado.
2. Dê permissão de execução ao script: `chmod +x backup_tool.sh`
3. Execute o script: `./backup_tool.sh`
4. Siga as instruções no menu interativo para realizar ou agendar um backup.

## Notas
- O script deve ser executado em um ambiente que suporte os comandos listados nos requisitos.
- As tarefas agendadas pelo cron serão executadas com base nas permissões do usuário que criou o agendamento.
