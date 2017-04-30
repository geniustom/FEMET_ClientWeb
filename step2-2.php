<?php
session_start();
include('../conn/config.php');
include('../function/function.php');
$sys=$_GET['sys'];
$dia=$_GET['dia'];
$hr=$_GET['hr'];
$glu=$_GET['glu'];
$mac=$_REQUEST['mac'];

?>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
 <script src="../js/save.js" type="text/javascript"></script>
<title><?php echo iconv("big5","UTF-8", Webname);?></title>
<script type="text/javascript" src="../js/preLoadingMessage1.js"></script>
<link rel="stylesheet" type="text/css" href="css/blue.css" id="skin" />
<link rel="stylesheet" type="text/css" href="css/style.css"  />
<script type="text/javascript" src="../js/jquery-1.3.2.min.js" ></script>
<script type="text/javascript" src="../js/skin.js" ></script>
<script src="../js/yu.js" type="text/javascript"></script>
<script src="../js/tb.js" type="text/javascript"></script>
<link href="css/css.css" rel="stylesheet" type="text/css" />
<script type="text/javascript">
$(document).ready(function(){
  swichStyle("skin","switch-skin","css/");
   //清除cookie,用于测试时清出cookie
   $("#clearCookie").click(function(){
        eraseCookie("style");
    });
});
</script>
<script type="text/javascript">
function sys_01()
{
  var strsys;
  var strdia;
  var strhr;
  var strglu;
  strsys=document.frm.sys.value;
  strdia=document.frm.dia.value;
  strhr=document.frm.hr.value;
  strglu=document.frm.glu.value;
  //document.frm.action="step2-3.php?sys="+strsys+"&amps;dia="+strdia+"&amps;hr="+strhr+"&amps;glu="+strglu;
  document.frm.action="step3.php?sys="+strsys+"&amps;dia="+strdia+"&amps;hr="+strhr+"&amps;glu="+strglu;
  document.frm.submit();
}
</script>
</head>
<body topmargin="0" leftmargin="0" bgcolor="#255A70" style="background-image: url('')" oncontextmenu="return false" onselectstart="return false" ondragstart="return false" >
<div id="mainDiv">
<ul id="switch-skin"><li id="green" ></li><li id="blue"></li><li id="default"></a></li></ul>
<div id="logo_img"> </div>
<div id="layer2"></div>

<div id="b001"></div>



<div id="body_ok">


<form name="frm" action="">
<div id="iindok1">
<p><span class="DD1">2</span><font color="19FF47">請量測血壓與脈搏，<br><span class="br_y">量測完畢請按下一步。</span></font></p>


<div class="br_y1">
<label>
<font size="6">收縮壓：<input type="text" name="sys" class="ssoid2" value="<?php echo $_GET['sys'];?>" maxlength=3 readonly>&nbsp;mm/Hg<br>
舒張壓：<input type="text" name="dia" class="ssoid2" value="<?php echo $_GET['dia'];?>" maxlength=3 readonly>&nbsp;mm/Hg<br>
脈　搏：<input type="text" name="hr" class="ssoid2" value="<?php echo $_GET['hr'];?>" maxlength=3 readonly>&nbsp;次/分鐘<br></font>
</label>
</div>


<!--<div class="gooj"><a href="step2-3.php"></a></div>-->
<div class="gooj_1"><a href="javascript:sys_01();"></a></div>

<div class="table_t"  style="top: 570px;">遠東醫電客戶服務免付費電話：0809-010-070</div>



<div class="table_H" style="top:470px">
<table width="350"><tr><td align="center" bgcolor="yellow" id="countdown"><font size=6></font></td></tr>
<tr><td  >&nbsp;</td></tr>
</table>

</div>

 </div>

<ul id="left_meun">
   <li class="cod_03"><a title="回上一頁"  href="step1.php?mac=<?php echo $mac;?>"></a></li>
   <li class="cod_04"><a title="回首頁"  href="step1.php?mac=<?php echo $mac;?>"></a></li>
 </ul>

<!--- 20170430 Tommy start--->
<input type="hidden" name="bp_measure_start" value=0>
<input type="hidden" name="bp_measure_errmsg" value="">
<div style="position: absolute;top:600px;left:200px">
<input type="button" onclick="javascript:window.alert('請將壓脈帶繫上於手臂後按 確定 繼續');bp_measure_start.value=1;" 
 value="開始量測">   
</div>
<script type="text/javascript">
function checkErr(){
   var errmsg=document.frm.bp_measure_errmsg.value;
   document.frm.bp_measure_errmsg.value=""
   if ( errmsg != "" ) {
     window.alert("量測異常: "+errmsg);
   }
   setTimeout("checkErr()",1000);
}
checkErr()
</script>
<!--- 20170430 Tommy end--->

<input type="hidden" name="glu" value="<?php echo $glu;?>">
<input type="hidden" name="mac" value="<?php echo $mac;?>">
</form>
<div id="gimg"><img src="images/A.jpg" width="300" height="199">
                步驟2-1.請將壓脈帶正確穿戴<br>
                步驟2-2.按下血壓機上開始按鈕<br>
                步驟2-3.血壓機自動充氣，壓脈帶膨脹<br>
                步驟2-4.血壓機自動監測血壓數值<br>
                步驟2-5.血壓機顯示血壓、脈搏等數值<br>
                步驟2-6.卸除壓脈帶，完成血壓量測。</div>


<div id="layer6">
<div id="b001_1"></div>
<p align="center"><?php echo iconv("big5","UTF-8", Copyright);?>
</div>

</div>
</body>
</html>
<script type="text/javascript">

//設定倒數秒數
var t = 181;

//顯示倒數秒收
function showTime()
{
    var strmac;
    strmac=document.frm.mac.value;
    t -= 1;
    if(t%2==0)
      document.getElementById('countdown').innerHTML='<font size="4">本網頁將於 '+t+' 秒後自動刷新</font>';
    else
      document.getElementById('countdown').innerHTML='';


    if(t<0)
    {
        document.getElementById('countdown').innerHTML='<font size="4">刷新中...</font>';
        location.href='step2-2.php?mac='+strmac;
    }

    //每秒執行一次,showTime()
    setTimeout("showTime()",1000);
}

//執行showTime()
showTime();
</script>



