<?php
if($_GET['lx']=="video"){
$content = file_get_contents("http://fuyhi.top/api/video_xjj/api.php?type=json");
$json = json_decode($content,true);
header("Location: {$json['url']}");}
   if($_GET['lx']!="video"){
   $content = file_get_contents("https://api.xiao-xin.top/API/ks_free.php?type=json");
$json = json_decode($content,true);
header("Location: {$json['video_png']}");}