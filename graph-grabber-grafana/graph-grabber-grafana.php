<?php

$config = array(
    'grafana' => array(
        'examplegrafana' => array(
            'apikey' => 'YOUR_GRAFANA_API_KEY',
        ),
    ),
    'grabber' => array(
        'savedir' => dirname(__DIR__) . '/graphs/',
        'graphs' => array(
            array(
                'grafana' => 'examplegrafana',
                'url' => 'https://monitoring.example.net/render/dashboard-solo/db/YOUR_DASHBOARD_NAME?orgId=1&var-node=YOUR_VARIABLE_NODE&var-device=YOUR_OTHER_VARIABLE&panelId=YOUR_PANEL_ID&from=now-24h&to=now&width=1200&height=500&tz=UTC%2B02%3A00',
                'name' => 'example-panel.png',
            ),
        ),
    ),
);

foreach ($config['grabber']['graphs'] as $graph) {
    echo "Downloading graph " . $graph['name'] . ' ...<br>';
    $ch = curl_init($graph['url']);
    curl_setopt_array($ch, array(
        CURLOPT_HEADER => 0,
        CURLOPT_RETURNTRANSFER => 1,
        CURLOPT_BINARYTRANSFER => 1,
        CURLOPT_HTTPHEADER => array(
            'Authorization: Bearer ' . $config['grafana'][$graph['grafana']]['apikey'],
        ),
    ));
    $raw = curl_exec($ch);
    curl_close ($ch);
    $saveto = $config['grabber']['savedir'] . $graph['name'];
    if (file_exists($saveto)) {
        unlink($saveto);
    }
    echo "Saving graph to " . $saveto . ' ...<br>';
    $fp = fopen($saveto, 'x');
    fwrite($fp, $raw);
    fclose($fp);
    echo "Saved graph to " . $saveto . '<br>';
    echo "Downloaded graph " . $graph['name'] . '.<br>';
    echo "===<br>";
}

