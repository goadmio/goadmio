<?php
/** Adminer - Compact database management
* @link https://www.adminer.org/
* @author Jakub Vrana, https://www.vrana.cz/
* @copyright 2007 Jakub Vrana
* @license https://www.apache.org/licenses/LICENSE-2.0 Apache License, Version 2.0
* @license https://www.gnu.org/licenses/gpl-2.0.html GNU General Public License, version 2 (one or other)
* @version 5.3.0
*/namespace
Adminer;const
VERSION="5.3.0";error_reporting(24575);set_error_handler(function($Fc,$Hc){return!!preg_match('~^Undefined (array key|offset|index)~',$Hc);},E_WARNING|E_NOTICE);$cd=!preg_match('~^(unsafe_raw)?$~',ini_get("filter.default"));if($cd||ini_get("filter.default_flags")){foreach(array('_GET','_POST','_COOKIE','_SERVER')as$X){$sj=filter_input_array(constant("INPUT$X"),FILTER_UNSAFE_RAW);if($sj)$$X=$sj;}}if(function_exists("mb_internal_encoding"))mb_internal_encoding("8bit");function
connection($h=null){return($h?:Db::$instance);}function
adminer(){return
Adminer::$instance;}function
driver(){return
Driver::$instance;}function
connect(){$Hb=adminer()->credentials();$J=Driver::connect($Hb[0],$Hb[1],$Hb[2]);return(is_object($J)?$J:null);}function
idf_unescape($v){if(!preg_match('~^[`\'"[]~',$v))return$v;$Ke=substr($v,-1);return
str_replace($Ke.$Ke,$Ke,substr($v,1,-1));}function
q($Q){return
connection()->quote($Q);}function
escape_string($X){return
substr(q($X),1,-1);}function
idx($xa,$y,$l=null){return($xa&&array_key_exists($y,$xa)?$xa[$y]:$l);}function
number($X){return
preg_replace('~[^0-9]+~','',$X);}function
number_type(){return'((?<!o)int(?!er)|numeric|real|float|double|decimal|money)';}function
remove_slashes(array$ah,$cd=false){if(function_exists("get_magic_quotes_gpc")&&get_magic_quotes_gpc()){while(list($y,$X)=each($ah)){foreach($X
as$Be=>$W){unset($ah[$y][$Be]);if(is_array($W)){$ah[$y][stripslashes($Be)]=$W;$ah[]=&$ah[$y][stripslashes($Be)];}else$ah[$y][stripslashes($Be)]=($cd?$W:stripslashes($W));}}}}function
bracket_escape($v,$Ea=false){static$bj=array(':'=>':1',']'=>':2','['=>':3','"'=>':4');return
strtr($v,($Ea?array_flip($bj):$bj));}function
min_version($Ij,$Ze="",$h=null){$h=connection($h);$Uh=$h->server_info;if($Ze&&preg_match('~([\d.]+)-MariaDB~',$Uh,$A)){$Uh=$A[1];$Ij=$Ze;}return$Ij&&version_compare($Uh,$Ij)>=0;}function
charset(Db$g){return(min_version("5.5.3",0,$g)?"utf8mb4":"utf8");}function
ini_bool($le){$X=ini_get($le);return(preg_match('~^(on|true|yes)$~i',$X)||(int)$X);}function
sid(){static$J;if($J===null)$J=(SID&&!($_COOKIE&&ini_bool("session.use_cookies")));return$J;}function
set_password($Hj,$N,$V,$F){$_SESSION["pwds"][$Hj][$N][$V]=($_COOKIE["adminer_key"]&&is_string($F)?array(encrypt_string($F,$_COOKIE["adminer_key"])):$F);}function
get_password(){$J=get_session("pwds");if(is_array($J))$J=($_COOKIE["adminer_key"]?decrypt_string($J[0],$_COOKIE["adminer_key"]):false);return$J;}function
get_val($H,$n=0,$vb=null){$vb=connection($vb);$I=$vb->query($H);if(!is_object($I))return
false;$K=$I->fetch_row();return($K?$K[$n]:false);}function
get_vals($H,$d=0){$J=array();$I=connection()->query($H);if(is_object($I)){while($K=$I->fetch_row())$J[]=$K[$d];}return$J;}function
get_key_vals($H,$h=null,$Xh=true){$h=connection($h);$J=array();$I=$h->query($H);if(is_object($I)){while($K=$I->fetch_row()){if($Xh)$J[$K[0]]=$K[1];else$J[]=$K[0];}}return$J;}function
get_rows($H,$h=null,$m="<p class='error'>"){$vb=connection($h);$J=array();$I=$vb->query($H);if(is_object($I)){while($K=$I->fetch_assoc())$J[]=$K;}elseif(!$I&&!$h&&$m&&(defined('Adminer\PAGE_HEADER')||$m=="-- "))echo$m.error()."\n";return$J;}function
unique_array($K,array$x){foreach($x
as$w){if(preg_match("~PRIMARY|UNIQUE~",$w["type"])){$J=array();foreach($w["columns"]as$y){if(!isset($K[$y]))continue
2;$J[$y]=$K[$y];}return$J;}}}function
escape_key($y){if(preg_match('(^([\w(]+)('.str_replace("_",".*",preg_quote(idf_escape("_"))).')([ \w)]+)$)',$y,$A))return$A[1].idf_escape(idf_unescape($A[2])).$A[3];return
idf_escape($y);}function
where(array$Z,array$o=array()){$J=array();foreach((array)$Z["where"]as$y=>$X){$y=bracket_escape($y,true);$d=escape_key($y);$n=idx($o,$y,array());$ad=$n["type"];$J[]=$d.(JUSH=="sql"&&$ad=="json"?" = CAST(".q($X)." AS JSON)":(JUSH=="sql"&&is_numeric($X)&&preg_match('~\.~',$X)?" LIKE ".q($X):(JUSH=="mssql"&&strpos($ad,"datetime")===false?" LIKE ".q(preg_replace('~[_%[]~','[\0]',$X)):" = ".unconvert_field($n,q($X)))));if(JUSH=="sql"&&preg_match('~char|text~',$ad)&&preg_match("~[^ -@]~",$X))$J[]="$d = ".q($X)." COLLATE ".charset(connection())."_bin";}foreach((array)$Z["null"]as$y)$J[]=escape_key($y)." IS NULL";return
implode(" AND ",$J);}function
where_check($X,array$o=array()){parse_str($X,$Ya);remove_slashes(array(&$Ya));return
where($Ya,$o);}function
where_link($t,$d,$Y,$Xf="="){return"&where%5B$t%5D%5Bcol%5D=".urlencode($d)."&where%5B$t%5D%5Bop%5D=".urlencode(($Y!==null?$Xf:"IS NULL"))."&where%5B$t%5D%5Bval%5D=".urlencode($Y);}function
convert_fields(array$e,array$o,array$M=array()){$J="";foreach($e
as$y=>$X){if($M&&!in_array(idf_escape($y),$M))continue;$ya=convert_field($o[$y]);if($ya)$J
.=", $ya AS ".idf_escape($y);}return$J;}function
cookie($B,$Y,$Se=2592000){header("Set-Cookie: $B=".urlencode($Y).($Se?"; expires=".gmdate("D, d M Y H:i:s",time()+$Se)." GMT":"")."; path=".preg_replace('~\?.*~','',$_SERVER["REQUEST_URI"]).(HTTPS?"; secure":"")."; HttpOnly; SameSite=lax",false);}function
get_settings($Db){parse_str($_COOKIE[$Db],$Yh);return$Yh;}function
get_setting($y,$Db="adminer_settings"){$Yh=get_settings($Db);return$Yh[$y];}function
save_settings(array$Yh,$Db="adminer_settings"){$Y=http_build_query($Yh+get_settings($Db));cookie($Db,$Y);$_COOKIE[$Db]=$Y;}function
restart_session(){if(!ini_bool("session.use_cookies")&&(!function_exists('session_status')||session_status()==1))session_start();}function
stop_session($kd=false){$_j=ini_bool("session.use_cookies");if(!$_j||$kd){session_write_close();if($_j&&@ini_set("session.use_cookies",'0')===false)session_start();}}function&get_session($y){return$_SESSION[$y][DRIVER][SERVER][$_GET["username"]];}function
set_session($y,$X){$_SESSION[$y][DRIVER][SERVER][$_GET["username"]]=$X;}function
auth_url($Hj,$N,$V,$k=null){$wj=remove_from_uri(implode("|",array_keys(SqlDriver::$drivers))."|username|ext|".($k!==null?"db|":"").($Hj=='mssql'||$Hj=='pgsql'?"":"ns|").session_name());preg_match('~([^?]*)\??(.*)~',$wj,$A);return"$A[1]?".(sid()?SID."&":"").($Hj!="server"||$N!=""?urlencode($Hj)."=".urlencode($N)."&":"").($_GET["ext"]?"ext=".urlencode($_GET["ext"])."&":"")."username=".urlencode($V).($k!=""?"&db=".urlencode($k):"").($A[2]?"&$A[2]":"");}function
is_ajax(){return($_SERVER["HTTP_X_REQUESTED_WITH"]=="XMLHttpRequest");}function
redirect($Ve,$mf=null){if($mf!==null){restart_session();$_SESSION["messages"][preg_replace('~^[^?]*~','',($Ve!==null?$Ve:$_SERVER["REQUEST_URI"]))][]=$mf;}if($Ve!==null){if($Ve=="")$Ve=".";header("Location: $Ve");exit;}}function
query_redirect($H,$Ve,$mf,$jh=true,$Mc=true,$Vc=false,$Oi=""){if($Mc){$ni=microtime(true);$Vc=!connection()->query($H);$Oi=format_time($ni);}$hi=($H?adminer()->messageQuery($H,$Oi,$Vc):"");if($Vc){adminer()->error
.=error().$hi.script("messagesPrint();")."<br>";return
false;}if($jh)redirect($Ve,$mf.$hi);return
true;}class
Queries{static$queries=array();static$start=0;}function
queries($H){if(!Queries::$start)Queries::$start=microtime(true);Queries::$queries[]=(preg_match('~;$~',$H)?"DELIMITER ;;\n$H;\nDELIMITER ":$H).";";return
connection()->query($H);}function
apply_queries($H,array$T,$Ic='Adminer\table'){foreach($T
as$R){if(!queries("$H ".$Ic($R)))return
false;}return
true;}function
queries_redirect($Ve,$mf,$jh){$eh=implode("\n",Queries::$queries);$Oi=format_time(Queries::$start);return
query_redirect($eh,$Ve,$mf,$jh,false,!$jh,$Oi);}function
format_time($ni){return
lang(0,max(0,microtime(true)-$ni));}function
relative_uri(){return
str_replace(":","%3a",preg_replace('~^[^?]*/([^?]*)~','\1',$_SERVER["REQUEST_URI"]));}function
remove_from_uri($ug=""){return
substr(preg_replace("~(?<=[?&])($ug".(SID?"":"|".session_name()).")=[^&]*&~",'',relative_uri()."&"),0,-1);}function
get_file($y,$Tb=false,$Zb=""){$bd=$_FILES[$y];if(!$bd)return
null;foreach($bd
as$y=>$X)$bd[$y]=(array)$X;$J='';foreach($bd["error"]as$y=>$m){if($m)return$m;$B=$bd["name"][$y];$Wi=$bd["tmp_name"][$y];$_b=file_get_contents($Tb&&preg_match('~\.gz$~',$B)?"compress.zlib://$Wi":$Wi);if($Tb){$ni=substr($_b,0,3);if(function_exists("iconv")&&preg_match("~^\xFE\xFF|^\xFF\xFE~",$ni))$_b=iconv("utf-16","utf-8",$_b);elseif($ni=="\xEF\xBB\xBF")$_b=substr($_b,3);}$J
.=$_b;if($Zb)$J
.=(preg_match("($Zb\\s*\$)",$_b)?"":$Zb)."\n\n";}return$J;}function
upload_error($m){$hf=($m==UPLOAD_ERR_INI_SIZE?ini_get("upload_max_filesize"):0);return($m?lang(1).($hf?" ".lang(2,$hf):""):lang(3));}function
repeat_pattern($Gg,$Qe){return
str_repeat("$Gg{0,65535}",$Qe/65535)."$Gg{0,".($Qe%65535)."}";}function
is_utf8($X){return(preg_match('~~u',$X)&&!preg_match('~[\0-\x8\xB\xC\xE-\x1F]~',$X));}function
format_number($X){return
strtr(number_format($X,0,".",lang(4)),preg_split('~~u',lang(5),-1,PREG_SPLIT_NO_EMPTY));}function
friendly_url($X){return
preg_replace('~\W~i','-',$X);}function
table_status1($R,$Wc=false){$J=table_status($R,$Wc);return($J?reset($J):array("Name"=>$R));}function
column_foreign_keys($R){$J=array();foreach(adminer()->foreignKeys($R)as$q){foreach($q["source"]as$X)$J[$X][]=$q;}return$J;}function
fields_from_edit(){$J=array();foreach((array)$_POST["field_keys"]as$y=>$X){if($X!=""){$X=bracket_escape($X);$_POST["function"][$X]=$_POST["field_funs"][$y];$_POST["fields"][$X]=$_POST["field_vals"][$y];}}foreach((array)$_POST["fields"]as$y=>$X){$B=bracket_escape($y,true);$J[$B]=array("field"=>$B,"privileges"=>array("insert"=>1,"update"=>1,"where"=>1,"order"=>1),"null"=>1,"auto_increment"=>($y==driver()->primary),);}return$J;}function
dump_headers($Sd,$wf=false){$J=adminer()->dumpHeaders($Sd,$wf);$qg=$_POST["output"];if($qg!="text")header("Content-Disposition: attachment; filename=".adminer()->dumpFilename($Sd).".$J".($qg!="file"&&preg_match('~^[0-9a-z]+$~',$qg)?".$qg":""));session_write_close();if(!ob_get_level())ob_start(null,4096);ob_flush();flush();return$J;}function
dump_csv(array$K){foreach($K
as$y=>$X){if(preg_match('~["\n,;\t]|^0|\.\d*0$~',$X)||$X==="")$K[$y]='"'.str_replace('"','""',$X).'"';}echo
implode(($_POST["format"]=="csv"?",":($_POST["format"]=="tsv"?"\t":";")),$K)."\r\n";}function
apply_sql_function($s,$d){return($s?($s=="unixepoch"?"DATETIME($d, '$s')":($s=="count distinct"?"COUNT(DISTINCT ":strtoupper("$s("))."$d)"):$d);}function
get_temp_dir(){$J=ini_get("upload_tmp_dir");if(!$J){if(function_exists('sys_get_temp_dir'))$J=sys_get_temp_dir();else{$p=@tempnam("","");if(!$p)return'';$J=dirname($p);unlink($p);}}return$J;}function
file_open_lock($p){if(is_link($p))return;$r=@fopen($p,"c+");if(!$r)return;chmod($p,0660);if(!flock($r,LOCK_EX)){fclose($r);return;}return$r;}function
file_write_unlock($r,$Nb){rewind($r);fwrite($r,$Nb);ftruncate($r,strlen($Nb));file_unlock($r);}function
file_unlock($r){flock($r,LOCK_UN);fclose($r);}function
first(array$xa){return
reset($xa);}function
password_file($i){$p=get_temp_dir()."/adminer.key";if(!$i&&!file_exists($p))return'';$r=file_open_lock($p);if(!$r)return'';$J=stream_get_contents($r);if(!$J){$J=rand_string();file_write_unlock($r,$J);}else
file_unlock($r);return$J;}function
rand_string(){return
md5(uniqid(strval(mt_rand()),true));}function
select_value($X,$_,array$n,$Ni){if(is_array($X)){$J="";foreach($X
as$Be=>$W)$J
.="<tr>".($X!=array_values($X)?"<th>".h($Be):"")."<td>".select_value($W,$_,$n,$Ni);return"<table>$J</table>";}if(!$_)$_=adminer()->selectLink($X,$n);if($_===null){if(is_mail($X))$_="mailto:$X";if(is_url($X))$_=$X;}$J=adminer()->editVal($X,$n);if($J!==null){if(!is_utf8($J))$J="\0";elseif($Ni!=""&&is_shortable($n))$J=shorten_utf8($J,max(0,+$Ni));else$J=h($J);}return
adminer()->selectVal($J,$_,$n,$X);}function
is_mail($wc){$za='[-a-z0-9!#$%&\'*+/=?^_`{|}~]';$ic='[a-z0-9]([-a-z0-9]{0,61}[a-z0-9])';$Gg="$za+(\\.$za+)*@($ic?\\.)+$ic";return
is_string($wc)&&preg_match("(^$Gg(,\\s*$Gg)*\$)i",$wc);}function
is_url($Q){$ic='[a-z0-9]([-a-z0-9]{0,61}[a-z0-9])';return
preg_match("~^(https?)://($ic?\\.)+$ic(:\\d+)?(/.*)?(\\?.*)?(#.*)?\$~i",$Q);}function
is_shortable(array$n){return
preg_match('~char|text|json|lob|geometry|point|linestring|polygon|string|bytea~',$n["type"]);}function
count_rows($R,array$Z,$ve,array$yd){$H=" FROM ".table($R).($Z?" WHERE ".implode(" AND ",$Z):"");return($ve&&(JUSH=="sql"||count($yd)==1)?"SELECT COUNT(DISTINCT ".implode(", ",$yd).")$H":"SELECT COUNT(*)".($ve?" FROM (SELECT 1$H GROUP BY ".implode(", ",$yd).") x":$H));}function
slow_query($H){$k=adminer()->database();$Pi=adminer()->queryTimeout();$ci=driver()->slowQuery($H,$Pi);$h=null;if(!$ci&&support("kill")){$h=connect();if($h&&($k==""||$h->select_db($k))){$Ee=get_val(connection_id(),0,$h);echo
script("const timeout = setTimeout(() => { ajax('".js_escape(ME)."script=kill', function () {}, 'kill=$Ee&token=".get_token()."'); }, 1000 * $Pi);");}}ob_flush();flush();$J=@get_key_vals(($ci?:$H),$h,false);if($h){echo
script("clearTimeout(timeout);");ob_flush();flush();}return$J;}function
get_token(){$hh=rand(1,1e6);return($hh^$_SESSION["token"]).":$hh";}function
verify_token(){list($Xi,$hh)=explode(":",$_POST["token"]);return($hh^$_SESSION["token"])==$Xi;}function
lzw_decompress($Ka){$ec=256;$La=8;$ib=array();$uh=0;$vh=0;for($t=0;$t<strlen($Ka);$t++){$uh=($uh<<8)+ord($Ka[$t]);$vh+=8;if($vh>=$La){$vh-=$La;$ib[]=$uh>>$vh;$uh&=(1<<$vh)-1;$ec++;if($ec>>$La)$La++;}}$dc=range("\0","\xFF");$J="";$Rj="";foreach($ib
as$t=>$hb){$vc=$dc[$hb];if(!isset($vc))$vc=$Rj.$Rj[0];$J
.=$vc;if($t)$dc[]=$Rj.$vc[0];$Rj=$vc;}return$J;}function
script($ei,$aj="\n"){return"<script".nonce().">$ei</script>$aj";}function
script_src($xj,$Wb=false){return"<script src='".h($xj)."'".nonce().($Wb?" defer":"")."></script>\n";}function
nonce(){return' nonce="'.get_nonce().'"';}function
input_hidden($B,$Y=""){return"<input type='hidden' name='".h($B)."' value='".h($Y)."'>\n";}function
input_token(){return
input_hidden("token",get_token());}function
target_blank(){return' target="_blank" rel="noreferrer noopener"';}function
h($Q){return
str_replace("\0","&#0;",htmlspecialchars($Q,ENT_QUOTES,'utf-8'));}function
nl_br($Q){return
str_replace("\n","<br>",$Q);}function
checkbox($B,$Y,$bb,$Ge="",$Wf="",$fb="",$Ie=""){$J="<input type='checkbox' name='$B' value='".h($Y)."'".($bb?" checked":"").($Ie?" aria-labelledby='$Ie'":"").">".($Wf?script("qsl('input').onclick = function () { $Wf };",""):"");return($Ge!=""||$fb?"<label".($fb?" class='$fb'":"").">$J".h($Ge)."</label>":$J);}function
optionlist($bg,$Mh=null,$Aj=false){$J="";foreach($bg
as$Be=>$W){$cg=array($Be=>$W);if(is_array($W)){$J
.='<optgroup label="'.h($Be).'">';$cg=$W;}foreach($cg
as$y=>$X)$J
.='<option'.($Aj||is_string($y)?' value="'.h($y).'"':'').($Mh!==null&&($Aj||is_string($y)?(string)$y:$X)===$Mh?' selected':'').'>'.h($X);if(is_array($W))$J
.='</optgroup>';}return$J;}function
html_select($B,array$bg,$Y="",$Vf="",$Ie=""){static$Ge=0;$He="";if(!$Ie&&substr($bg[""],0,1)=="("){$Ge++;$Ie="label-$Ge";$He="<option value='' id='$Ie'>".h($bg[""]);unset($bg[""]);}return"<select name='".h($B)."'".($Ie?" aria-labelledby='$Ie'":"").">".$He.optionlist($bg,$Y)."</select>".($Vf?script("qsl('select').onchange = function () { $Vf };",""):"");}function
html_radios($B,array$bg,$Y="",$Qh=""){$J="";foreach($bg
as$y=>$X)$J
.="<label><input type='radio' name='".h($B)."' value='".h($y)."'".($y==$Y?" checked":"").">".h($X)."</label>$Qh";return$J;}function
confirm($mf="",$Nh="qsl('input')"){return
script("$Nh.onclick = () => confirm('".($mf?js_escape($mf):lang(6))."');","");}function
print_fieldset($u,$Pe,$Lj=false){echo"<fieldset><legend>","<a href='#fieldset-$u'>$Pe</a>",script("qsl('a').onclick = partial(toggle, 'fieldset-$u');",""),"</legend>","<div id='fieldset-$u'".($Lj?"":" class='hidden'").">\n";}function
bold($Na,$fb=""){return($Na?" class='active $fb'":($fb?" class='$fb'":""));}function
js_escape($Q){return
addcslashes($Q,"\r\n'\\/");}function
pagination($D,$Kb){return" ".($D==$Kb?$D+1:'<a href="'.h(remove_from_uri("page").($D?"&page=$D".($_GET["next"]?"&next=".urlencode($_GET["next"]):""):"")).'">'.($D+1)."</a>");}function
hidden_fields(array$ah,array$Wd=array(),$Sg=''){$J=false;foreach($ah
as$y=>$X){if(!in_array($y,$Wd)){if(is_array($X))hidden_fields($X,array(),$y);else{$J=true;echo
input_hidden(($Sg?$Sg."[$y]":$y),$X);}}}return$J;}function
hidden_fields_get(){echo(sid()?input_hidden(session_name(),session_id()):''),(SERVER!==null?input_hidden(DRIVER,SERVER):""),input_hidden("username",$_GET["username"]);}function
enum_input($U,$_a,array$n,$Y,$zc=null){preg_match_all("~'((?:[^']|'')*)'~",$n["length"],$cf);$J=($zc!==null?"<label><input type='$U'$_a value='$zc'".((is_array($Y)?in_array($zc,$Y):$Y===$zc)?" checked":"")."><i>".lang(7)."</i></label>":"");foreach($cf[1]as$t=>$X){$X=stripcslashes(str_replace("''","'",$X));$bb=(is_array($Y)?in_array($X,$Y):$Y===$X);$J
.=" <label><input type='$U'$_a value='".h($X)."'".($bb?' checked':'').'>'.h(adminer()->editVal($X,$n)).'</label>';}return$J;}function
input(array$n,$Y,$s,$Da=false){$B=h(bracket_escape($n["field"]));echo"<td class='function'>";if(is_array($Y)&&!$s){$Y=json_encode($Y,128|64|256);$s="json";}$th=(JUSH=="mssql"&&$n["auto_increment"]);if($th&&!$_POST["save"])$s=null;$td=(isset($_GET["select"])||$th?array("orig"=>lang(8)):array())+adminer()->editFunctions($n);$fc=stripos($n["default"],"GENERATED ALWAYS AS ")===0?" disabled=''":"";$_a=" name='fields[$B]'$fc".($Da?" autofocus":"");$Ec=driver()->enumLength($n);if($Ec){$n["type"]="enum";$n["length"]=$Ec;}echo
driver()->unconvertFunction($n)." ";$R=$_GET["edit"]?:$_GET["select"];if($n["type"]=="enum")echo
h($td[""])."<td>".adminer()->editInput($R,$n,$_a,$Y);else{$Fd=(in_array($s,$td)||isset($td[$s]));echo(count($td)>1?"<select name='function[$B]'$fc>".optionlist($td,$s===null||$Fd?$s:"")."</select>".on_help("event.target.value.replace(/^SQL\$/, '')",1).script("qsl('select').onchange = functionChange;",""):h(reset($td))).'<td>';$ne=adminer()->editInput($R,$n,$_a,$Y);if($ne!="")echo$ne;elseif(preg_match('~bool~',$n["type"]))echo"<input type='hidden'$_a value='0'>"."<input type='checkbox'".(preg_match('~^(1|t|true|y|yes|on)$~i',$Y)?" checked='checked'":"")."$_a value='1'>";elseif($n["type"]=="set"){preg_match_all("~'((?:[^']|'')*)'~",$n["length"],$cf);foreach($cf[1]as$t=>$X){$X=stripcslashes(str_replace("''","'",$X));$bb=in_array($X,explode(",",$Y),true);echo" <label><input type='checkbox' name='fields[$B][$t]' value='".h($X)."'".($bb?' checked':'').">".h(adminer()->editVal($X,$n)).'</label>';}}elseif(preg_match('~blob|bytea|raw|file~',$n["type"])&&ini_bool("file_uploads"))echo"<input type='file' name='fields-$B'>";elseif($s=="json"||preg_match('~^jsonb?$~',$n["type"]))echo"<textarea$_a cols='50' rows='12' class='jush-js'>".h($Y).'</textarea>';elseif(($Li=preg_match('~text|lob|memo~i',$n["type"]))||preg_match("~\n~",$Y)){if($Li&&JUSH!="sqlite")$_a
.=" cols='50' rows='12'";else{$L=min(12,substr_count($Y,"\n")+1);$_a
.=" cols='30' rows='$L'";}echo"<textarea$_a>".h($Y).'</textarea>';}else{$mj=driver()->types();$jf=(!preg_match('~int~',$n["type"])&&preg_match('~^(\d+)(,(\d+))?$~',$n["length"],$A)?((preg_match("~binary~",$n["type"])?2:1)*$A[1]+($A[3]?1:0)+($A[2]&&!$n["unsigned"]?1:0)):($mj[$n["type"]]?$mj[$n["type"]]+($n["unsigned"]?0:1):0));if(JUSH=='sql'&&min_version(5.6)&&preg_match('~time~',$n["type"]))$jf+=7;echo"<input".((!$Fd||$s==="")&&preg_match('~(?<!o)int(?!er)~',$n["type"])&&!preg_match('~\[\]~',$n["full_type"])?" type='number'":"")." value='".h($Y)."'".($jf?" data-maxlength='$jf'":"").(preg_match('~char|binary~',$n["type"])&&$jf>20?" size='".($jf>99?60:40)."'":"")."$_a>";}echo
adminer()->editHint($R,$n,$Y);$dd=0;foreach($td
as$y=>$X){if($y===""||!$X)break;$dd++;}if($dd&&count($td)>1)echo
script("qsl('td').oninput = partial(skipOriginal, $dd);");}}function
process_input(array$n){if(stripos($n["default"],"GENERATED ALWAYS AS ")===0)return;$v=bracket_escape($n["field"]);$s=idx($_POST["function"],$v);$Y=$_POST["fields"][$v];if($n["type"]=="enum"||driver()->enumLength($n)){if($Y==-1)return
false;if($Y=="")return"NULL";}if($n["auto_increment"]&&$Y=="")return
null;if($s=="orig")return(preg_match('~^CURRENT_TIMESTAMP~i',$n["on_update"])?idf_escape($n["field"]):false);if($s=="NULL")return"NULL";if($n["type"]=="set")$Y=implode(",",(array)$Y);if($s=="json"){$s="";$Y=json_decode($Y,true);if(!is_array($Y))return
false;return$Y;}if(preg_match('~blob|bytea|raw|file~',$n["type"])&&ini_bool("file_uploads")){$bd=get_file("fields-$v");if(!is_string($bd))return
false;return
driver()->quoteBinary($bd);}return
adminer()->processInput($n,$Y,$s);}function
search_tables(){$_GET["where"][0]["val"]=$_POST["query"];$Ph="<ul>\n";foreach(table_status('',true)as$R=>$S){$B=adminer()->tableName($S);if(isset($S["Engine"])&&$B!=""&&(!$_POST["tables"]||in_array($R,$_POST["tables"]))){$I=connection()->query("SELECT".limit("1 FROM ".table($R)," WHERE ".implode(" AND ",adminer()->selectSearchProcess(fields($R),array())),1));if(!$I||$I->fetch_row()){$Wg="<a href='".h(ME."select=".urlencode($R)."&where[0][op]=".urlencode($_GET["where"][0]["op"])."&where[0][val]=".urlencode($_GET["where"][0]["val"]))."'>$B</a>";echo"$Ph<li>".($I?$Wg:"<p class='error'>$Wg: ".error())."\n";$Ph="";}}}echo($Ph?"<p class='message'>".lang(9):"</ul>")."\n";}function
on_help($ob,$ai=0){return
script("mixin(qsl('select, input'), {onmouseover: function (event) { helpMouseover.call(this, event, $ob, $ai) }, onmouseout: helpMouseout});","");}function
edit_form($R,array$o,$K,$vj,$m=''){$zi=adminer()->tableName(table_status1($R,true));page_header(($vj?lang(10):lang(11)),$m,array("select"=>array($R,$zi)),$zi);adminer()->editRowPrint($R,$o,$K,$vj);if($K===false){echo"<p class='error'>".lang(12)."\n";return;}echo"<form action='' method='post' enctype='multipart/form-data' id='form'>\n";if(!$o)echo"<p class='error'>".lang(13)."\n";else{echo"<table class='layout'>".script("qsl('table').onkeydown = editingKeydown;");$Da=!$_POST;foreach($o
as$B=>$n){echo"<tr><th>".adminer()->fieldName($n);$l=idx($_GET["set"],bracket_escape($B));if($l===null){$l=$n["default"];if($n["type"]=="bit"&&preg_match("~^b'([01]*)'\$~",$l,$qh))$l=$qh[1];if(JUSH=="sql"&&preg_match('~binary~',$n["type"]))$l=bin2hex($l);}$Y=($K!==null?($K[$B]!=""&&JUSH=="sql"&&preg_match("~enum|set~",$n["type"])&&is_array($K[$B])?implode(",",$K[$B]):(is_bool($K[$B])?+$K[$B]:$K[$B])):(!$vj&&$n["auto_increment"]?"":(isset($_GET["select"])?false:$l)));if(!$_POST["save"]&&is_string($Y))$Y=adminer()->editVal($Y,$n);$s=($_POST["save"]?idx($_POST["function"],$B,""):($vj&&preg_match('~^CURRENT_TIMESTAMP~i',$n["on_update"])?"now":($Y===false?null:($Y!==null?'':'NULL'))));if(!$_POST&&!$vj&&$Y==$n["default"]&&preg_match('~^[\w.]+\(~',$Y))$s="SQL";if(preg_match("~time~",$n["type"])&&preg_match('~^CURRENT_TIMESTAMP~i',$Y)){$Y="";$s="now";}if($n["type"]=="uuid"&&$Y=="uuid()"){$Y="";$s="uuid";}if($Da!==false)$Da=($n["auto_increment"]||$s=="now"||$s=="uuid"?null:true);input($n,$Y,$s,$Da);if($Da)$Da=false;echo"\n";}if(!support("table")&&!fields($R))echo"<tr>"."<th><input name='field_keys[]'>".script("qsl('input').oninput = fieldChange;")."<td class='function'>".html_select("field_funs[]",adminer()->editFunctions(array("null"=>isset($_GET["select"]))))."<td><input name='field_vals[]'>"."\n";echo"</table>\n";}echo"<p>\n";if($o){echo"<input type='submit' value='".lang(14)."'>\n";if(!isset($_GET["select"]))echo"<input type='submit' name='insert' value='".($vj?lang(15):lang(16))."' title='Ctrl+Shift+Enter'>\n",($vj?script("qsl('input').onclick = function () { return !ajaxForm(this.form, '".lang(17)."…', this); };"):"");}echo($vj?"<input type='submit' name='delete' value='".lang(18)."'>".confirm()."\n":"");if(isset($_GET["select"]))hidden_fields(array("check"=>(array)$_POST["check"],"clone"=>$_POST["clone"],"all"=>$_POST["all"]));echo
input_hidden("referer",(isset($_POST["referer"])?$_POST["referer"]:$_SERVER["HTTP_REFERER"])),input_hidden("save",1),input_token(),"</form>\n";}function
shorten_utf8($Q,$Qe=80,$ti=""){if(!preg_match("(^(".repeat_pattern("[\t\r\n -\x{10FFFF}]",$Qe).")($)?)u",$Q,$A))preg_match("(^(".repeat_pattern("[\t\r\n -~]",$Qe).")($)?)",$Q,$A);return
h($A[1]).$ti.(isset($A[2])?"":"<i>…</i>");}function
icon($Rd,$B,$Qd,$Ri){return"<button type='submit' name='$B' title='".h($Ri)."' class='icon icon-$Rd'><span>$Qd</span></button>";}if(isset($_GET["file"])){if(substr(VERSION,-4)!='-dev'){if($_SERVER["HTTP_IF_MODIFIED_SINCE"]){header("HTTP/1.1 304 Not Modified");exit;}header("Expires: ".gmdate("D, d M Y H:i:s",time()+365*24*60*60)." GMT");header("Last-Modified: ".gmdate("D, d M Y H:i:s")." GMT");header("Cache-Control: immutable");}@ini_set("zlib.output_compression",'1');if($_GET["file"]=="default.css"){header("Content-Type: text/css; charset=utf-8");echo
