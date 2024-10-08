<?php
if (isset($_GET['url'])) {
    $url = $_GET['url'];
    // Inicializa a sessão cURL
    $ch = curl_init();

    // Configura a URL de destino
    curl_setopt($ch, CURLOPT_URL, $url);

    // Indica que a resposta deve ser retornada como string
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

    // Desativa a verificação SSL (não recomendado para produção)
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);

    // Executa a requisição
    $response = curl_exec($ch);

    // Verifica por erros
    if (curl_errno($ch)) {
        echo 'Erro na requisição: ' . curl_error($ch);
    } else {
        // Exibe a resposta
        echo $response;
    }

    // Fecha a sessão cURL
    curl_close($ch);
} else {
    echo "Nenhuma URL foi fornecida.";
}
?>