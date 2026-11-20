@echo off
rem cria uma tarefa que inicia o bot sozinho quando voce entra no Windows
schtasks /Create /TN "AutoReconnectBot" /TR "\"%~dp0iniciar.bat\"" /SC ONLOGON /RL LIMITED /F
echo Pronto. O bot vai iniciar junto com o Windows.
pause
