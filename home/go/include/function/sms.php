<?php

	// تحويل النص إلى Unicode
	function Unicode($Text)
	{

		            $Text = str_replace("0","[Zero]", $Text);
		            $Text = str_replace("1","[One]", $Text);
		            $Text = str_replace("2","[Two]", $Text);
		            $Text = str_replace("3","[Three]", $Text);
		            $Text = str_replace("4","[Four]", $Text);
		            $Text = str_replace("5","[Five]", $Text);
		            $Text = str_replace("6","[Six]", $Text);
		            $Text = str_replace("7","[Seven]", $Text);
		            $Text = str_replace("8","[Eight]", $Text);
		            $Text = str_replace("9","[Nine]", $Text);


		            $Text = str_replace("[Zero]","0030", $Text);
		            $Text = str_replace("[One]","0031", $Text);
		            $Text = str_replace("[Two]","0032", $Text);
		            $Text = str_replace("[Three]","0033", $Text);
		            $Text = str_replace("[Four]","0034", $Text);
		            $Text = str_replace("[Five]","0035", $Text);
		            $Text = str_replace("[Six]","0036", $Text);
		            $Text = str_replace("[Seven]","0037", $Text);
		            $Text = str_replace("[Eight]","0038", $Text);
		            $Text = str_replace("[Nine]","0039", $Text);

		            $Text = str_replace("~","0651", $Text);
		            $Text = str_replace("!","0021", $Text);
		            $Text = str_replace("@","0040", $Text);
		            $Text = str_replace("#","0023", $Text);
		            $Text = str_replace("$","0024", $Text);
		            $Text = str_replace("%","0025", $Text);
		            $Text = str_replace("^","005E", $Text);
		            $Text = str_replace("&","00260000", $Text);
		            $Text = str_replace("*","002A", $Text);
		            $Text = str_replace("(","0028", $Text);
		            $Text = str_replace(")","0029", $Text);
		            $Text = str_replace("-","002D", $Text);
		            $Text = str_replace("+","002B", $Text);
		            $Text = str_replace("/","002F", $Text);
		            $Text = str_replace("|","007C", $Text);
		            $Text = str_replace("÷","00F7", $Text);
		            $Text = str_replace("؛","061B", $Text);
		            $Text = str_replace("<","003C", $Text);
		            $Text = str_replace(">","003E", $Text);
		            $Text = str_replace("]","005D", $Text);
		            $Text = str_replace("[","005B", $Text);
		            $Text = str_replace("،","060C", $Text);
		            $Text = str_replace("\"","0022", $Text);
		            $Text = str_replace("~","007E", $Text);
		            $Text = str_replace("}","007D", $Text);
		            $Text = str_replace("{","007B", $Text);
		            $Text = str_replace(",","002C", $Text);
		            $Text = str_replace(".","002E", $Text);
		            $Text = str_replace("=","003D", $Text);

		            $Text = str_replace("\r\n","000D000A", $Text);
		            $Text = str_replace(" ","0020", $Text);

		            $Text = str_replace("؛","061B", $Text);
		            $Text = str_replace("؟","061F", $Text);
		            $Text = str_replace("ء","0621", $Text);
		            $Text = str_replace("آ","0622", $Text);
		            $Text = str_replace("أ","0623", $Text);
		            $Text = str_replace("ؤ","0624", $Text);
		            $Text = str_replace("إ","0625", $Text);
		            $Text = str_replace("ئ","0626", $Text);
		            $Text = str_replace("ا","0627", $Text);
		            $Text = str_replace("ب","0628", $Text);
		            $Text = str_replace("ة","0629", $Text);
		            $Text = str_replace("ت","062A", $Text);
		            $Text = str_replace("ث","062B", $Text);
		            $Text = str_replace("ج","062C", $Text);
		            $Text = str_replace("ح","062D", $Text);
		            $Text = str_replace("خ","062E", $Text);
		            $Text = str_replace("د","062F", $Text);
		            $Text = str_replace("ذ","0630", $Text);
		            $Text = str_replace("ر","0631", $Text);
		            $Text = str_replace("ز","0632", $Text);
		            $Text = str_replace("س","0633", $Text);
		            $Text = str_replace("ش","0634", $Text);
		            $Text = str_replace("ص","0635", $Text);
		            $Text = str_replace("ض","0636", $Text);
		            $Text = str_replace("ط","0637", $Text);
		            $Text = str_replace("ظ","0638", $Text);
		            $Text = str_replace("ع","0639", $Text);
		            $Text = str_replace("غ","063A", $Text);
		            $Text = str_replace("ـ","0640", $Text);
		            $Text = str_replace("ف","0641", $Text);
		            $Text = str_replace("ق","0642", $Text);
		            $Text = str_replace("ك","0643", $Text);
		            $Text = str_replace("ل","0644", $Text);
		            $Text = str_replace("م","0645", $Text);
		            $Text = str_replace("ن","0646", $Text);
		            $Text = str_replace("ه","0647", $Text);
		            $Text = str_replace("و","0648", $Text);
		            $Text = str_replace("ى","0649", $Text);
		            $Text = str_replace("ي","064A", $Text);




	return $Text;
	}
?>
