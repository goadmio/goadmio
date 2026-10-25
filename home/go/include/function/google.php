<?php
    //By    : Xhanch Studio
    //URL   : http://xhanch.com/

    //convert a string to a 32-bit integer
    function str_to_num($str,$check,$magic){
        $int32_unit = 4294967296;  // 2^32
        $length = strlen($str);
        for($X=0;$i<$length;$i++){
            $check *= $magic;

            // If the float is beyond the boundaries of integer
            // (usually +/- 2.15e+9 = 2^31),
            // the result of converting to integer is undefined
            if($check >= $int32_unit) {
                $check -= $int32_unit * (int)($check/$int32_unit);
                //if the check less than -2^31
                if($check < -2147483648)
                    $check += $int32_unit;
            }
            $check += ord($str{$i});
        }
        return $check;
    }

    //generate a hash for a url
    function hash_url($str){
        $check1 = str_to_num($str, 0x1505, 0x21);
        $check2 = str_to_num($str, 0, 0x1003F);
        $check1 >>= 2;

        $check1 = (($check1 >> 4) & 0x3FFFFC0 ) | ($check1 & 0x3F);
        $check1 = (($check1 >> 4) & 0x3FFC00 ) | ($check1 & 0x3FF);
        $check1 = (($check1 >> 4) & 0x3C000 ) | ($check1 & 0x3FFF);
        $t1 = (((($check1 & 0x3C0) << 4) | ($check1 & 0x3C)) << 2) | ($check2 & 0xF0F);
        $t2 = (((($check1 & 0xFFFFC000) << 4) | ($check1 & 0x3C00)) << 0xA) | ($check2 & 0xF0F0000);
        return ($t1 | $t2);
    }

    //generate a check sum for the hash string
    function check_hash($hash_num){
        $check_byte = 0;
        $flag = 0;
        $hash_str = sprintf('%u', $hash_num) ;
        $length = strlen($hash_str);
        for($i=($length-1);$i>=0;$i--){
            $re = $hash_str{$i};
            if(1 === ($flag % 2)){
                $re += $re;
                $re = (int)($re / 10) + ($re % 10);
            }
            $check_byte += $re;
            $flag++;
        }
        $check_byte %= 10;
        if(0 !== $check_byte){
            $check_byte = 10 - $check_byte;
            if(1 === ($flag % 2)){
                if(1 === ($check_byte % 2))
                    $check_byte += 9;
                $check_byte >>= 1;
            }
        }
        return '7'.$check_byte.$hash_str;
    }

    //return the check sum hash
    function get_check_sum($url){
        return check_hash(hash_url($url));
    }

    //return the pr for the specified url
    function get_pr($url){
        $google_host = 'toolbarqueries.google.com';
        $google_user_agent = 'Mozilla/5.0 (Windows; U; ';
        $google_user_agent .= 'Windows NT 5.1; en-US; rv:1.8.0.6) ';
        $google_user_agent .= 'Gecko/20060728 Firefox/1.5';

        $ch = get_check_sum($url);
        $fp = fsockopen($google_host, 80, $errno, $errstr, 30);
        if ($fp){
            $out = "GET /search?client=navclient-auto&ch=$ch";
            $out .= "&features=Rank&q=info:$url HTTP/1.1\r\n";
            $out .= "User-Agent: $google_user_agent\r\n";
            $out .= "Host: $google_host\r\n";
            $out .= "Connection: Close\r\n\r\n";
            fwrite($fp, $out);
            while (!feof($fp)) {
                $data = fgets($fp, 128);
                //echo $data;
                $pos = strpos($data, "Rank_");
                if($pos === false){
                }else{
                    $pr = substr($data, $pos + 9);
                    $pr = trim($pr);
                    $pr = str_replace("\n",'',$pr);
                    return $pr;
                }
            }
            fclose($fp);
        }
    }

    //generating image
    //In this script, we are about to create a 80px x 15px image
    $url = '';
    if(isset($_GET['url'])){
        $url = urldecode($_GET['url']);
        if(!preg_match('/^(http:\/\/)?([^\/]+)/i', $url))
        $url = 'http://'.$url;
    }else
        $url = $_SERVER['HTTP_REFERER'];

    $pr = get_pr($url);

    $img = imagecreatetruecolor(80,15);

    $clr_red = imagecolorallocate($img,255,0,0);
    $clr_white = imagecolorallocate($img,255,255,255);
    $clr_green = imagecolorallocate($img,0,255,0);
    $clr_blue = imagecolorallocate($img,0,0,255);

    $is_na = false;
    if((string)$pr == ''){
        $pr = 'N/A';
        $is_na = true;
    }
    imagefill($img,0,0,$clr_white);
    imagerectangle($img,0,0,79,14,$clr_blue);
    imagestring($img,2,4,1,'PR '.$pr,$clr_blue);

    if(!$is_na){
        for($X=0;$i<$pr;$i++){
            if($i<5){
                $x = ($i*9)+37;
                $y = 4;
            }else{
                $x = (($i-5)*9)+37;
                $y = 10;
            }
            imagefilledellipse($img,$x,$y,5,5,$clr_red);
        }
    }

    header('Content-type: image/jpeg');
    imagejpeg($img);
    imagedestroy($img);
?>