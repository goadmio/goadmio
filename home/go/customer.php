<?php
include "navigator.php";
$Buttons="";
include "title.php";

echo "<div class=NavigatorInfo><img src='theme/{$_SESSION['SessionTheme']}/image/info.svg' height=24 style='vertical-align:middle;padding-$OAlign:8px'>This feature is supported only on physical server hardware and will not function on VPS (Virtual Private Server) or cloud-based environments</div>";

$Edit=$_REQUEST['Edit'];
$CustomerID=$_REQUEST['CustomerID'];

$Name=trim($_REQUEST['Name']);
$Email=ValidateEmail($_REQUEST['Email'],"Invalid Email.");
$Password=ValidatePassword($_REQUEST['Password']);
$Company=trim($_REQUEST['Company']);
$Address=trim($_REQUEST['Address']);
$City=trim($_REQUEST['City']);
$ZipCode=trim($_REQUEST['ZipCode']);
$Country=trim($_REQUEST['Country']);
$Mobile=trim($_REQUEST['Mobile']);

If ($Delete==1 and $Step==1)
{
        echo Error("Delete Customer \"{$Name}\" ? <a href=\"javascript:Load('$CurrentFileName?Delete=1&ControlID=$ServiceID&CustomerID=$CustomerID&Name=$Name&Step=2','$ControlID')\" class=Action>Yes</a> <a href=\"javascript:Load('$CurrentFileName?ControlID=$ControlID','$ControlID')\" class=Action>No</a>");

        exit;
}

if ($Delete==1 and $Step==2)
{

        SQL("DELETE from Customer where CustomerID='$CustomerID'");
        echo Error("Customer $Name has been deleted.");


}
elseif ($Name!="" and $Action!="Edit")
{

        if ($Edit==1)
        {

                SQL("UPDATE Customer SET Name='$Name',Email='$Email',Company='$Company',Address='$Address',City='$City',ZipCode='$ZipCode',Country='$Country',Mobile='$Mobile' where CustomerID='$CustomerID'");

                if ($Password!="")
                {
                $Salt=RandomSalt();
                $Password=md5("$Password|$Salt");
                }

                SQL("UPDATE Customer SET Password='$Password',Salt='$Salt' where CustomerID='$CustomerID'");


                echo Error("Customer $Name updated successfully.");


                $Edit="";

                $Name="";
                $Email="";
                $Password="";
                $Company="";
                $Address="";
                $City="";
                $ZipCode="";
                $Country="";
                $Mobile="";

        }
        else
        {

                $EmailExists=0;
                $Sql = "select Email from Customer where Email='$Email'";
                $Result = SQL($Sql);
                foreach ($Result as $Row)
                { 
                        $EmailExists=1;
                }

                if ($EmailExists==0)
                {
                $TimeStamp=time();

                $Salt=RandomSalt();
                $Password=md5("$Password|$Salt");

            SQL("INSERT INTO Customer (Name,Email,Password,Salt,Company,Address,City,ZipCode,Country,Mobile,TimeStamp) VALUES ('$Name','$Email','$Password','$Salt','$Company','$Address','$City','$ZipCode','$Country','$Mobile','$TimeStamp')");
                echo Error("Customer $Name added successfully.");

                $Name="";
                $Email="";
                $Password="";
                $Company="";
                $Address="";
                $City="";
                $ZipCode="";
                $Country="";
                $Mobile="";
                }
                else
                {
                echo Error("Sorry, Customer Email $Email already exists.");
                }

        }
}

        if ($Edit==1)
        {
                $Sql = "select * from Customer where CustomerID='$CustomerID'";
                $Result = SQL($Sql);
                foreach ($Result as $Row)
                { 

                        $Name=$Row['Name'];
                        $Email=$Row['Email'];
                        $Company=$Row['Company'];
                        $Address=$Row['Address'];
                        $City=$Row['City'];
                        $ZipCode=$Row['ZipCode'];
                        $Country=$Row['Country'];
                        $Mobile=$Row['Mobile'];

                }

        }

        Echo "
        <form name=\"Form\" method=\"POST\" onsubmit=\"return Submit('$CurrentFileName');\" autocomplete=\"off\" action=\"$CurrentFileName\">
        <input type=hidden name=CustomerID value='$CustomerID'>
        <input type=hidden name=Edit value='$Edit'>

        <div class='DivInput {$Dir}DivInput'>{$LNG['CustomerName']}<br>
        <input type='text' name='Name' value='$Name' maxlength=100 class=InputText>
        </div>

        <div class='DivInput {$Dir}DivInput'>
        {$LNG['Email']}<br>
        <input type='text' name='Email' value='$Email' maxlength=100 class=InputText>
        </div>

        <div class='DivInput {$Dir}DivInput'>{$LNG['Password']}<br>
        <input type='text' name='Password' value='$Password' maxlength=100 class=InputText>
        </div>

        <div class='DivInput {$Dir}DivInput'>{$LNG['Company']}<br>
        <input type='text' name='Company' value='$Company' maxlength=100 class=InputText>
        </div>

        <div class='DivInput {$Dir}DivInput'>{$LNG['Address']}<br>
        <input type='text' name='Address' value='$Address' maxlength=100 class=InputText>
        </div>

        <div class='DivInput {$Dir}DivInput'>{$LNG['City']}<br>
        <input type='text' name='City' value='$City' maxlength=100 class=InputText>
        </div>

        <div class='DivInput {$Dir}DivInput'>{$LNG['ZipCode']}<br>
        <input type='text' name='ZipCode' value='$ZipCode' maxlength=100 class=InputText>
        </div>

        <div class='DivInput {$Dir}DivInput'>{$LNG['Country']}<br>
        <input type='text' name='Country' value='$Country' maxlength=100 class=InputText>
        </div>

        <div class='DivInput {$Dir}DivInput'>{$LNG['Mobile']}<br>
        <input type='text' name='Mobile' value='$Mobile' maxlength=100 class=InputText>
        </div>

        <div id=DivSubmit class=DivSubmit>

        ";

        if ($Edit==1)
        {
                Echo "<input type=submit value='{$LNG['SaveChanges']}' Class=InputButton>";
        }
        else
        {
                Echo "<input type=submit value='{$LNG['AddCustomer']}' Class=InputButton>";
        }


        Echo "
        </div>

</form>


";


        if($Edit!=1)
        {

                include "search.php";

                Echo "
                <div class=DivXTable>
                <table cellPadding='8' cellSpacing='0' width='100%' class='Table'>

                <THEAD>

                <tr>


                <th align='$DAlign' width='2%'>

                </th>


                <th align='$DAlign' width='20%'>
                <a href=\"javascript:Load('$CurrentFileName?&SortBy=Name')\">Name</a>
                </th>

                <th align='$DAlign' width='20%'>
                <a href=\"javascript:Load('$CurrentFileName?&SortBy=Email')\">Email</a>
                </th>


                <th align='$DAlign' width='20%'>
                <a href=\"javascript:Load('$CurrentFileName?&SortBy=Balance')\">Balance</a>
                </th>


                <th width='38%'>

                </span>
                </th>

                </tr>

                </THEAD>

                ";

                $Table="Customer";$Field="CustomerID>=1";
                $DefaultSortBy="CustomerID";
                $DefaultDirection="DESC";
                include "include/sql.php";

                $X=0;
                $Result = SQL($Sql);
                foreach ($Result as $Row)
                {

                        $CustomerID=$Row['CustomerID'];
                        $Email=$Row['Email'];

                        if ($X==0)
                        {
                        echo "<TBODY>";
                        }

                        if ($X%2==0)
                        {
                        $TDColor="Td";
                        }
                        else
                        {
                        $TDColor="TdB";
                        }


                        $CreatedDate=date("D j M Y g:i a", $Row['TimeStamp']);


                        Echo "
                        <tr name=R$i id=R$i divid=Find find='{$Row['Email']}' class='$TDColor'>

                        <TD align='middle'>
                        {$Row['CustomerID']}
                        </TD>

                        <TD>{$Row['Name']}</TD>

                        <TD>{$Row['Email']}</TD>

                        <TD>{$Row['Balance']}</TD>

                        <TD align='$OAlign'>

                        <a href=\"javascript:Load('$CurrentFileName?Edit=1&Action=Edit&CustomerID={$Row['CustomerID']}&Name={$Row['Name']}')\" class=Action>Edit</a>&nbsp;
                        <a href=\"javascript:Load('$CurrentFileName?Delete=1&Step=1&CustomerID={$Row['CustomerID']}&Name={$Row['Name']}')\" class=Action>Delete</a>&nbsp;
                        <a href='iframe/funds.php?CustomerID=$CustomerID' data-fancybox data-type='iframe' class=Action>{$LNG['AddFunds']}</a>


                        </TD>
                        ";

                $X++;
                }


                if ($X!=0)
                {
                echo "</TBODY>";
                }

                echo "
                <TFOOT>

                <tr>

                <th align='$DAlign' colspan=2>
                Showing $X of $RowsNo records.
                </th>

                <th align='$OAlign' colspan=2>
                ";

                include "pages.php";

                echo "
                </th>

                </tr>

                </TFOOT>

                </TABLE>
                </div>
                </form>
                ";



        }


echo "
</div>
";
?>