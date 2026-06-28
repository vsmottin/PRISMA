# Estágios do Pipeline

Este diretório agrupa os componentes usados exclusivamente no _datapath_ com **Pipeline**, conhecidos como **Registradores de Estágio**.

Esses registradores funcionam como "barreiras" sincronizadas pelo _clock_. Eles capturam os dados processados e os sinais de controle gerados por um estágio, repassando-os de maneira estável para o próximo estágio no ciclo seguinte.
