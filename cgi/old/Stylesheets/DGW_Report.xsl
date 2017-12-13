<!-- 
 Copyright 1995-2012 Ellucian Company L.P. and its affiliates. 
 $Id: //Tuxedo/RELEASE/Product/webroot/DGW_Report.xsl#12 $ -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"> 
<!--
TODO: The block radio button needs the req-id and node-id=0
TODO: The rule radio button needs the req-id in addition to its node-id
Colors:
000066 - darker blue
660000 - dark red
CCCC99 - dark beige
EE0000 - bright red
88bbff - light blue 2
F4F4F4 - light grey
&#160; - space
-->


<!-- Variables available for customizing -->
<xsl:variable name="LabelProgressBar">    Degree Progress </xsl:variable>
<xsl:variable name="LabelStillNeeded">    Still Needed:  </xsl:variable>
<xsl:variable name="LabelAlertsReminders">  Alerts and Reminders </xsl:variable>
<xsl:variable name="LabelFallthrough">      Electives </xsl:variable>
<xsl:variable name="LabelInprogress">       In-progress </xsl:variable>
<xsl:variable name="LabelOTL">              Not Counted </xsl:variable>
<xsl:variable name="LabelInsufficient">     No Credit Received </xsl:variable>
<xsl:variable name="LabelSplitCredits">     Split Credits </xsl:variable>
<xsl:variable name="LabelPlaceholders">     Planner Placeholders </xsl:variable>
<xsl:variable name="LabelIncludedBlocks">   Blocks included in this block</xsl:variable>
<xsl:variable name="vShowTitleCreditsInHint">Y</xsl:variable>
<xsl:variable name="vLabelSchool"     >Level</xsl:variable>
<xsl:variable name="vLabelDegree"     >Degree</xsl:variable>
<xsl:variable name="vLabelMajor"      >Major</xsl:variable>
<xsl:variable name="vLabelMinor"      >Minor</xsl:variable>
<xsl:variable name="vLabelCollege"    >College</xsl:variable>
<xsl:variable name="vLabelLevel"      >Classification</xsl:variable>
<xsl:variable name="vLabelAdvisor"    >Advisor</xsl:variable>
<xsl:variable name="vLabelStudentID"  >ID</xsl:variable>
<xsl:variable name="vLabelStudentName">Student</xsl:variable>
<xsl:variable name="vLabelOverallGPA" >Overall GPA</xsl:variable>
<xsl:variable name="vGetCourseInfoFromServer">Y</xsl:variable>
<xsl:variable name="vGPADecimals">0.000</xsl:variable>
<xsl:variable name="vCreditDecimals">0.###</xsl:variable>
<xsl:variable name="vProgressBarPercent">Y</xsl:variable>
<xsl:variable name="vProgressBarCredits">Y</xsl:variable>
<xsl:variable name="vProgressBarRulesText">Percentage of requirements completed</xsl:variable>
<xsl:variable name="vProgressBarCreditsText">Percentage of credits completed</xsl:variable>
<xsl:variable name="vShowPetitions">N</xsl:variable>
<xsl:variable name="vShowToInsteadOfColon">Y</xsl:variable> <!-- ":" is replaced with " to " in classes/credits range -->

<xsl:variable name="vShowCourseSignals">Y</xsl:variable>
<xsl:variable name="CourseSignalsHelpUrl">http://helpme.myschool.edu</xsl:variable>
<xsl:variable name="CourseSignalsRedLow"    >You are very much at risk of failing this class</xsl:variable>
<xsl:variable name="CourseSignalsRedHigh"   >You are at risk of failing this class</xsl:variable>
<xsl:variable name="CourseSignalsYellowLow" >You are doing okay but could do better</xsl:variable>
<xsl:variable name="CourseSignalsYellowHigh">You are doing okay but could do better</xsl:variable>
<xsl:variable name="CourseSignalsGreenLow"  >You are doing well - keep it up!</xsl:variable>
<xsl:variable name="CourseSignalsGreenHigh" >You are doing very well - keep it up!</xsl:variable>

<xsl:key name="XptKey"    match="Audit/ExceptionList/Exception" use="@Id_num"/>
<xsl:key name="ClsKey"    match="Audit/Clsinfo/Class" use="@Id_num"/>
<xsl:key name="BlockKey"  match="Audit/Block" use="@Req_id"/>
<xsl:key name="BlockKey2" match="Audit/Block" use="@Req_type"/>
<xsl:key name="HeadQualKey" match="Header/Qualifier" use="@Node_id"/>

<xsl:template match="Audit">
<html>
   <link rel="stylesheet" href="DGW_Style.css" type="text/css" />
<body style="margin: 5px;">

<form name="frmAudit" ID="frmAudit">

<!-- Output all the block/rule information -->
<xsl:call-template name="tBlocks" />

<!-- Refresh student context area with this data -->
<xsl:call-template name="tRefreshStudentData" />
</form>

</body>
</html>
</xsl:template> <!-- match=Audit -->

<xsl:template name="tRefreshStudentData">
<xsl:for-each select="/Report/StudentData" >
<script  type="text/javascript" language="JavaScript">

function FindCode (sPicklistArray, sCodeToFind)
{
   var sReturnValue = sCodeToFind;

   for ( iSearchIndex = 0 ; iSearchIndex &lt; sPicklistArray.length ; iSearchIndex++ )
   {
      if (sPicklistArray[iSearchIndex].code == sCodeToFind)
      {
         sReturnValue = sPicklistArray[iSearchIndex].literal;
         break;
      }
   }
   return sReturnValue;
}

function Update_oViewClass (oStudentToUpdate, sMajors, sLevels, sDegrees)
{
   /*
      [0] = sort name
      [1] = name
      [3] = ID
      [4] = name
      [5] = degree short literal (list separated with space)
      [6] = major literal (list separated with space)
      [7] = school literal (list separated with space)
      [8] = level literal (list separated with space)
   */
      
   oStudentToUpdate[1] = "<xsl:value-of select='PrimaryMst/@Name' />";
   oStudentToUpdate[3] = "<xsl:value-of select='PrimaryMst/@Id' />";
   oStudentToUpdate[4] = "<xsl:value-of select='PrimaryMst/@Name' />";

      /*alert( "myPreviousDegree = " + oStudentToUpdate[5] + "\n" + 
            "myPreviousLevel  = " + oStudentToUpdate[8] + "\n" + 
            "myPreviousMajor  = " + oStudentToUpdate[6] + "\n");*/
   oStudentToUpdate[5] = '';
   oStudentToUpdate[6] = '';
   oStudentToUpdate[8] = '';

   <xsl:for-each select="GoalDtl">
      /* get the degree code, major code, school code, and level code. */     
      myDegree = FindCode (sDegrees, "<xsl:value-of select='@Degree' />");
      myLevel = FindCode (sLevels, "<xsl:value-of select='@StuLevel' />");
      thisDegree = "<xsl:value-of select='@Degree' />";
      myMajor = "";
      <xsl:for-each select="../GoalDataDtl[@GoalCode='MAJOR']">
         if (thisDegree == "<xsl:value-of select='@Degree' />" &amp;&amp; myMajor == "")
         {
            myMajor = FindCode (sMajors, "<xsl:value-of select='@GoalValue' />");
         }
      </xsl:for-each>
      oStudentToUpdate[5] += top.frControl.Trim(myDegree) + ' ';
      oStudentToUpdate[6] += top.frControl.Trim(myMajor)  + ' ';
      oStudentToUpdate[8] += top.frControl.Trim(myLevel)  + ' ';
      /*alert("Degree Info after:\n" + 
            "myPreviousDegree = " + oStudentToUpdate[5] + "\n" + 
            "myPreviousLevel  = " + oStudentToUpdate[8] + "\n" + 
            "myPreviousMajor  = " + oStudentToUpdate[6] + "\n");*/
   </xsl:for-each>
   /*
   oStudentToUpdate[5] = '';
   oStudentToUpdate[6] = '';
   oStudentToUpdate[7] = '';
   oStudentToUpdate[8] = '';
   */
   return oStudentToUpdate;

}
function Update_studentArray (aStudentToUpdate, sMajors, sLevels, sDegrees)
{
/*
   this.degree = Trim(degree);
   this.degreelit = Trim(degreelit);
   this.school = Trim(school);
   this.majorlit = Trim(majorlit);
   this.level = Trim(level);
   this.degreeinterest = Trim(degreeinterest);
*/
   aStudentToUpdate.name = "<xsl:value-of select='PrimaryMst/@Name' />";

   sRefreshDate = top.frControl.FormatRefreshDate("<xsl:value-of select='PrimaryMst/@BridgeDate' />");
   sRefreshTime = top.frControl.FormatRefreshTime("<xsl:value-of select='PrimaryMst/@BridgeTime' />");
   aStudentToUpdate.refreshdate = sRefreshDate + " at " + sRefreshTime;
   
   myAuditId = '<xsl:value-of select="/Report/Audit/AuditHeader/@Audit_id" />';
   if (myAuditId.substring(0,1) == "A") // if it is a real audit then update the auditdate otherwise do not.
   {
      aStudentToUpdate.auditdate = "Today";
   }
   
   aStudentToUpdate.degrees.length = 0;

   <xsl:for-each select="GoalDtl">
   myDegree = FindCode (sDegrees, "<xsl:value-of select='@Degree' />");
   myLevel  = FindCode (sLevels, "<xsl:value-of select='@StuLevel' />");
   thisDegree = "<xsl:value-of select='@Degree' />";
   myMajor = "";
   <xsl:for-each select="../GoalDataDtl[@GoalCode='MAJOR']">
      if (thisDegree == "<xsl:value-of select='@Degree' />" &amp;&amp; myMajor == "")
      {
         myMajor = FindCode (sMajors, "<xsl:value-of select='@GoalValue' />");
      }
   </xsl:for-each>
   aStudentToUpdate.degrees[aStudentToUpdate.degrees.length] = 
         new top.frControl.DegreeEntry("<xsl:value-of select='@Degree' />", 
                                myDegree, 
                                "<xsl:value-of select='@School' />", myMajor, myLevel, "");
   </xsl:for-each>
} // update_studentarray

<xsl:if test="PrimaryMst">
  //alert('"<xsl:value-of select="PrimaryMst/@Name" />" was successfully refreshed.');                                 
  var moz;
  moz = (typeof document.implementation != 'undefined') &amp;&amp; 
        (typeof document.implementation.createDocument != 'undefined');
/*
  if (moz)
    {
    thisForm   = top.frControl.document.getElementById("formCallScript");
    thisForm.elements['PRELOADEDPLAN'].value = "<xsl:value-of select="/Save/@PreloadedPlan" />"
    thisForm.elements['RELOADSEP'].value = "FALSE";
   }
  else // ie etc
    {
    top.frControl.frmCallScript.PRELOADEDPLAN.value = '<xsl:value-of select="/Save/@PreloadedPlan" />';
    top.frControl.frmCallScript.RELOADSEP.value = "FALSE";                      
    }
*/
   //alert("top.frControl.studentArray.length = " + top.frControl.studentArray.length);
  var sRefreshedStudentID   = '<xsl:value-of select="PrimaryMst/@Id" />';
  var sRefreshedStudentName = "<xsl:value-of select='PrimaryMst/@Name' />";

   //alert('Student just refreshed = ' + sRefreshedStudentID + '\n' + sRefreshedStudentName);

   //alert("top.frControl.sa.length = " + top.frControl.sa.length);

   var bOnlySimpleSearch = true;
   if (top.frControl.oViewClass != undefined)
   {
      bOnlySimpleSearch = false;
   }
   if (!bOnlySimpleSearch)
   {
      var oStudentList = top.frControl.oViewClass;
      var iStudentListLength = oStudentList.length;

      //alert("iStudentListLength = " + iStudentListLength);

      for ( iStudentArrayIndex = 0; iStudentArrayIndex &lt; iStudentListLength ; iStudentArrayIndex++ )
      {
         var bIsDefined = true;
         var i = 0;
         while (bIsDefined)
         {
            if (oStudentList[iStudentArrayIndex][i] != undefined)
            {
               if (oStudentList[iStudentArrayIndex][i] == sRefreshedStudentID)
               {
                  //alert("I found " + sRefreshedStudentID + " in my list!");
                  top.frControl.oViewClass[iStudentArrayIndex] = Update_oViewClass (
                                 top.frControl.oViewClass[iStudentArrayIndex],
                                 top.frControl.sMajorPicklist,
                                 top.frControl.sLevelPicklist,
                                 top.frControl.sDegreePicklist);
                  //bIsDefined = false;
               }
               //alert("oStudentList[" + iStudentArrayIndex + "][" + i + "] = " + oStudentList[iStudentArrayIndex][i]);
            }
            else
            {
               bIsDefined = false;
            }
            i++;
         }
      }
   }

   var aStudentArray = top.frControl.studentArray;
   var iStudentArrayLength = aStudentArray.length;
   var iCurrentDegreeIndex = top.frControl.oDegreeList.selectedIndex;

   //alert("iStudentArrayLength = " + iStudentArrayLength);
   for ( iStudentArrayIndex = 0; iStudentArrayIndex &lt; iStudentArrayLength ; iStudentArrayIndex++ )
   {
      if (aStudentArray[iStudentArrayIndex].id == sRefreshedStudentID)
      {
         //alert("I found " + sRefreshedStudentID + " in my second list!");
         Update_studentArray (top.frControl.studentArray[iStudentArrayIndex],
                     top.frControl.sMajorPicklist,
                     top.frControl.sLevelPicklist,
                     top.frControl.sDegreePicklist)
      }
      //alert("aStudentArray[" + iStudentArrayIndex + "].auditdate = " + aStudentArray[iStudentArrayIndex].auditdate);
   }
    // Set student context but do not reload body (reason for "false")
    // Keep the currently select degree as the one selected
    top.frControl.SetStudent(false, iCurrentDegreeIndex); 

</xsl:if>

</script>
</xsl:for-each > <!-- StudentData node -->

<script type="text/javascript" language="JavaScript">
<xsl:if test="not(/Report/StudentData/PrimaryMst)">
  if (typeof(top.frControl) != "undefined")
   {
   myAuditId = '<xsl:value-of select="/Report/Audit/AuditHeader/@Audit_id" />';
   // if it is a real audit then update the auditdate otherwise do not
   if (myAuditId.substring(0,1) == "A") 
    {
    sTodaysDate = top.frControl.GetCurrentDate(); // mm/dd/ccyy or whatever the format is
    sAuditDate = top.frControl.FormatDate ("<xsl:value-of select="concat(/Report/Audit/AuditHeader/@DateYear,/Report/Audit/AuditHeader/@DateMonth,/Report/Audit/AuditHeader/@DateDay)" />");
    //sAuditMonth = '<xsl:value-of select="/Report/Audit/AuditHeader/@DateMonth" />';
    //sAuditDay   = '<xsl:value-of select="/Report/Audit/AuditHeader/@DateDay"   />';
    //sAuditYear  = '<xsl:value-of select="/Report/Audit/AuditHeader/@DateYear"  />';
    //sAuditDate = sAuditMonth + '/' + sAuditDay + '/' + sAuditYear;
    // If this audit was run today then show its time; otherwise the date of the last
    // run audit should already be displaying and there is no reason to show this old date
    if (sAuditDate == sTodaysDate)
      {
      //sAuditHour  = '<xsl:value-of select="/Report/Audit/AuditHeader/@TimeHour"  />';
      //sAuditMin   = '<xsl:value-of select="/Report/Audit/AuditHeader/@TimeMinute"/>';
      //sDisplayDate = sAuditHour + ':' + sAuditMin;
      sDisplayDate = 'Today';
      // Update the display date at the top with this new date
      top.frControl.document.frmHoldFields.LastAudit.value = sDisplayDate;
      }
    }
   } // frcontrol != undefined
</xsl:if> <!-- not primarymst -->
</script>

</xsl:template>

<xsl:template name="tCreditsLiteral"> <!-- 1.19 -->
<xsl:choose>
 <xsl:when test="@Credits = 1">
  <xsl:value-of select="normalize-space(/Report/@rptCreditSingular)" />
 </xsl:when>
 <xsl:otherwise>
  <xsl:value-of select="normalize-space(/Report/@rptCreditsLiteral)" />
 </xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template name="tSectionPlaceholders">
   <table border="0" cellspacing="1" cellpadding="0" width="100%" class="Blocks">
      <tr>
         <td colspan="20">
         <table border="0" cellspacing="0" cellpadding="0" width="100%" class="BlockHeader">
         <tr >
            <td class="BlockHeader" colspan="1" rowspan="2" valign="middle" nowrap="true">
               &#160;
               <xsl:copy-of select="$LabelPlaceholders" />
            </td>
         </tr>
      </table>
      </td>
   </tr>

   <xsl:for-each select="/Report/Audit/Placeholders/Placeholder">
   <tr>
        <xsl:if test="position() mod 2 = 0">
         <xsl:attribute name="class">CourseAppliedRowAlt</xsl:attribute>
        </xsl:if>
        <xsl:if test="position() mod 2 = 1">
         <xsl:attribute name="class">CourseAppliedRowWhite</xsl:attribute>
        </xsl:if>

      <td class="SectionCourseTitle" >
        <xsl:value-of select="@Description"/> 
       </td>
      <td class="SectionCourseTitle" >
        <xsl:value-of select="@Value"/> 
       </td>
   </tr>
   </xsl:for-each>
   </table>
</xsl:template>

<xsl:template name="tSectionTemplate">
<xsl:param name="pSectionType" />
<xsl:param name="pSectionLabel" />

<xsl:for-each select="$pSectionType">
<xsl:if test="@Classes &gt; 0">
   <table border="0" cellspacing="1" cellpadding="0" width="100%" class="Blocks">
      <tr>

         <td colspan="20">
         <table border="0" cellspacing="0" cellpadding="0" width="100%" class="BlockHeader">

         <tr >
            <td class="BlockHeader" colspan="1" rowspan="2" valign="middle" nowrap="true">
               &#160;
               <xsl:copy-of select="$pSectionLabel" />
            </td>
            <td align="right" width="30%">
            <!-- New table for cat-yr, gpa, credits/classes required, credits/classes applied -->
            <table border="0" cellspacing="1" cellpadding="2" width="100%" class="BlockHeader">
               <tr>
                  <td class="SectionTableSubTitle" align="right">
                            <xsl:call-template name="tCreditsLiteral"/>
                     Applied: 
                  </td>
                  <td class="SectionTableSubData" align="right">
                     <xsl:call-template name="tFormatNumber" >
                        <xsl:with-param name="iNumber" select="@Credits" />
                        <xsl:with-param name="sRoundingMethod" select="$vCreditDecimals" />
                        </xsl:call-template>
                  </td>
                  <td class="SectionTableSubTitle">
                     Classes Applied: 
                  </td>
                  <td class="SectionTableSubData" align="right">
                     <xsl:value-of select="@Classes"/>
                  </td>
               </tr>  
            </table>
            </td>
         </tr>
      </table>
      </td>
   </tr>

   <xsl:if test="/Report/@rptShowClassCourseKeysOnly='Y'">
   <tr >
        <xsl:if test="position() mod 2 = 0">
         <xsl:attribute name="class">CourseAppliedRowAlt</xsl:attribute>
        </xsl:if>
        <xsl:if test="position() mod 2 = 1">
         <xsl:attribute name="class">CourseAppliedRowWhite</xsl:attribute>
        </xsl:if>
      <td class="ClassesAppliedClassesKeyOnly" >
      <xsl:for-each select="Class">
         <xsl:choose>
         <!--<xsl:when test="@Id_num &gt; 499">-->  <!-- 1.17 -->
         <xsl:when test="@Letter_grade = 'PLAN'">
            <font color="blue">
                     (<xsl:value-of select="@Discipline"/>        <!-- left paren + Discipline -->
                     <xsl:text>&#160;</xsl:text>                  <!-- space --> 
                     <xsl:value-of select="@Number"/>)            <!-- Number + right paren -->
            </font>
            <xsl:if test="position()!=last()">, </xsl:if>  <!-- comma (if not last one in the series) -->
         </xsl:when> 
         <xsl:otherwise>
            <xsl:value-of select="@Discipline"/>
            <xsl:text>&#160;</xsl:text> <!-- space --> 
            <xsl:value-of select="@Number"/> 
            <xsl:if test="key('ClsKey',@Id_num)/@In_progress='Y'">&#160;(IP)</xsl:if> <!-- (IP) = In-progress -->
            <xsl:if test="key('ClsKey',@Id_num)/@Transfer='T'">&#160;(T)</xsl:if> <!-- (T) = Transfer -->
            <xsl:if test="position()!=last()">, </xsl:if>  <!-- comma -->
         </xsl:otherwise>
         </xsl:choose>
      </xsl:for-each>
      </td>
   </tr>
   </xsl:if> <!-- show-course-keys-only = Y -->

   <xsl:if test="/Report/@rptShowClassCourseKeysOnly='N'">
   <xsl:for-each select="Class">
      <tr >
     <!-- <xsl:if test="@Id_num &gt; 499">-->
      <xsl:if test="@Letter_grade = 'PLAN'">
         <xsl:attribute name="style">
            color:blue;
         </xsl:attribute>
      </xsl:if>
        <xsl:if test="position() mod 2 = 0">
         <xsl:attribute name="class">CourseAppliedRowAlt</xsl:attribute>
        </xsl:if>
        <xsl:if test="position() mod 2 = 1">
         <xsl:attribute name="class">CourseAppliedRowWhite</xsl:attribute>
        </xsl:if>
         <td class="ClassesAppliedClasses"  >
            <xsl:value-of select="@Discipline"/>
            <xsl:text>&#160;</xsl:text> <!-- space --> 
            <xsl:value-of select="@Number"/>    
         </td>
         <td xxxwidth="50%" class="SectionCourseTitle">
            <!-- Title: -->
            <!-- Use the Id_num attribute on this node to lookup the Class info
            on the Clsinfo/Cass node and get the Title -->     
            <xsl:value-of select="key('ClsKey',@Id_num)/@Course_title"/>
         </td>
         <!-- Show the reason the class is in the OTL list if this is the OTL list  -->
            <xsl:if test="@Reason">
         <td class="SectionCourseTitle">
                <a title="This is why this class was not counted">
                  <xsl:call-template name="globalReplace">
                    <xsl:with-param name="outputString" select="@Reason"/>
                    <xsl:with-param name="target"       select="'credits'"/>
                    <xsl:with-param name="replacement"  select="normalize-space(/Report/@rptCreditsLiteral)"/>
                  </xsl:call-template>
                </a>
            <xsl:text>&#160;</xsl:text> <!-- space --> 
         </td>
            </xsl:if>

         <td class="SectionCourseGrade">
              <xsl:call-template name="tCourseSignalsGrade"/>
         </td>
         <td class="SectionCourseCredits">
              <xsl:call-template name="CheckInProgressAndPolicy5"/>
         </td>
         <td class="SectionCourseTerm"> <!-- Perform a lookup on the Clsinfo/Class to get the term -->
            <xsl:value-of select="key('ClsKey',@Id_num)/@TermLit"/>
         </td>
      </tr>

      <!-- If this is a transfer class show more information -->
      <xsl:if test="key('ClsKey',@Id_num)/@Transfer='T'">
      <tr >
        <xsl:if test="position() mod 2 = 0">
         <xsl:attribute name="class">CourseAppliedRowAlt</xsl:attribute>
        </xsl:if>
        <xsl:if test="position() mod 2 = 1">
         <xsl:attribute name="class">CourseAppliedRowWhite</xsl:attribute>
        </xsl:if>
         <td class="SectionTransferLine"  colspan="5">
            <b>
            Satisfied by: &#160;
            </b>
            <xsl:value-of select="key('ClsKey',@Id_num)/@Transfer_course"/>
            <!-- Show the transfer course title and transfer school name - if they exist -->                        
            <xsl:if test="normalize-space(key('ClsKey',@Id_num)/@TransferTitle) != ''"> 
              <xsl:text> - </xsl:text> <!-- hyphen --> 
              <xsl:value-of select="key('ClsKey',@Id_num)/@TransferTitle"/>
            </xsl:if>
            <xsl:if test="normalize-space(key('ClsKey',@Id_num)/@Transfer_school) != ''"> 
              <xsl:text> - </xsl:text> <!-- hyphen --> 
              <xsl:value-of select="key('ClsKey',@Id_num)/@Transfer_school"/>
            </xsl:if>
         </td>
      </tr>
      </xsl:if>
   </xsl:for-each>
   </xsl:if> <!-- show-course-keys-only = N -->
   </table>
</xsl:if>
</xsl:for-each> 
</xsl:template>

<xsl:template name="tSectionInprogress">

<xsl:for-each select="In_progress">
<xsl:if test="@Classes &gt; 0">
   <table border="0" cellspacing="1" cellpadding="0" width="100%" class="Blocks">
      <tr>

         <td colspan="20">
         <table border="0" cellspacing="0" cellpadding="0" width="100%" class="BlockHeader">

         <tr >
            <td class="BlockHeader" colspan="1" rowspan="2" valign="middle" nowrap="true">
               &#160;
               <xsl:copy-of select="$LabelInprogress" />
            </td>
            <td align="right" width="30%">
            <!-- New table for cat-yr, gpa, credits/classes required, credits/classes applied -->
            <table border="0" cellspacing="1" cellpadding="2" width="100%" class="BlockHeader">
               <tr>
                  <td class="SectionTableSubTitle" align="right">
                            <xsl:call-template name="tCreditsLiteral"/>
                     Applied: 
                  </td>
                  <td class="SectionTableSubData" align="right">
                     <xsl:call-template name="tFormatNumber" >
                        <xsl:with-param name="iNumber" select="@Credits" />
                        <xsl:with-param name="sRoundingMethod" select="$vCreditDecimals" />
                        </xsl:call-template>
                  </td>
                  <td class="SectionTableSubTitle">
                     Classes Applied: 
                  </td>
                  <td class="SectionTableSubData" align="right">
                     <xsl:value-of select="@Classes"/>
                  </td>
               </tr>  
            </table>
            </td>
         </tr>
      </table>
      </td>
   </tr>

   <xsl:if test="/Report/@rptShowClassCourseKeysOnly='Y'">
   <tr >
        <xsl:if test="position() mod 2 = 0">
         <xsl:attribute name="class">CourseAppliedRowAlt</xsl:attribute>
        </xsl:if>
        <xsl:if test="position() mod 2 = 1">
         <xsl:attribute name="class">CourseAppliedRowWhite</xsl:attribute>
        </xsl:if>
      <td class="ClassesAppliedClassesKeyOnly" >
      <xsl:for-each select="Class">
         <xsl:choose>
         <!--<xsl:when test="@Id_num &gt; 499">-->  <!-- 1.17 -->
         <xsl:when test="@Letter_grade = 'PLAN'">
            <font color="blue">
                     (<xsl:value-of select="@Discipline"/>        <!-- left paren + Discipline -->
                     <xsl:text>&#160;</xsl:text>                  <!-- space --> 
                     <xsl:value-of select="@Number"/>)            <!-- Number + right paren -->
            </font>
            <xsl:if test="position()!=last()">, </xsl:if>  <!-- comma (if not last one in the series) -->
         </xsl:when> 
         <xsl:otherwise>
            <xsl:value-of select="@Discipline"/>
            <xsl:text>&#160;</xsl:text> <!-- space --> 
            <xsl:value-of select="@Number"/> 
            <xsl:if test="key('ClsKey',@Id_num)[@In_progress='Y']/@In_progress='Y'">&#160;(IP)</xsl:if> <!-- (IP) = In-progress -->
            <xsl:if test="key('ClsKey',@Id_num)[@In_progress='Y']/@Transfer='T'">&#160;(T)</xsl:if> <!-- (T) = Transfer -->
            <xsl:if test="position()!=last()">, </xsl:if>  <!-- comma -->
         </xsl:otherwise>
         </xsl:choose>
      </xsl:for-each>
      </td>
   </tr>
   </xsl:if> <!-- show-course-keys-only = Y -->

   <xsl:if test="/Report/@rptShowClassCourseKeysOnly='N'">
   <xsl:for-each select="Class">
      <tr >
      <!--<xsl:if test="@Id_num &gt; 499">-->
      <xsl:if test="@Letter_grade = 'PLAN'">
         <xsl:attribute name="style">
            color:blue;
         </xsl:attribute>
      </xsl:if>
        <xsl:if test="position() mod 2 = 0">
         <xsl:attribute name="class">CourseAppliedRowAlt</xsl:attribute>
        </xsl:if>
        <xsl:if test="position() mod 2 = 1">
         <xsl:attribute name="class">CourseAppliedRowWhite</xsl:attribute>
        </xsl:if>
         <!-- COURSE KEY -->
         <td class="ClassesAppliedClasses"  >
            <xsl:value-of select="@Discipline"/>
            <xsl:text>&#160;</xsl:text> <!-- space --> 
            <xsl:value-of select="@Number"/>    
         </td>
         <!-- TITLE -->
         <td width="50%" class="SectionCourseTitle">
            <!-- Title: -->
            <!-- Use the Id_num attribute on this node to lookup the Class info
            on the Clsinfo/Cass node and get the Title -->     
            <xsl:value-of select="key('ClsKey',@Id_num)[@In_progress='Y']/@Course_title"/>
         </td>
         <!-- GRADE -->
         <td class="SectionCourseGrade">
              <xsl:call-template name="tCourseSignalsGrade"/>
         </td>
         <!-- CREDITS -->
         <td class="SectionCourseCredits">
            <xsl:call-template name="tFormatNumber" >
                        <xsl:with-param name="iNumber" select="@Credits" />
                        <xsl:with-param name="sRoundingMethod" select="$vCreditDecimals" />
                        </xsl:call-template>
         </td>
         <!-- TERM -->
         <td class="SectionCourseTerm"> <!-- Perform a lookup on the Clsinfo/Class to get the term -->
            <xsl:value-of select="key('ClsKey',@Id_num)[@In_progress='Y']/@TermLit"/>
         </td>
      </tr>

      <!-- If this is a transfer class show more information -->
      <xsl:if test="key('ClsKey',@Id_num)[@In_progress='Y']/@Transfer='T'">
      <tr >
        <xsl:if test="position() mod 2 = 0">
         <xsl:attribute name="class">CourseAppliedRowAlt</xsl:attribute>
        </xsl:if>
        <xsl:if test="position() mod 2 = 1">
         <xsl:attribute name="class">CourseAppliedRowWhite</xsl:attribute>
        </xsl:if>
         <td class="SectionTransferLine"  colspan="5">
            <b>
            Satisfied by: &#160;
            </b>
            <xsl:value-of select="key('ClsKey',@Id_num)/@Transfer_course"/>
            <!-- Show the transfer course title and transfer school name - if they exist -->                        
            <xsl:if test="normalize-space(key('ClsKey',@Id_num)/@TransferTitle) != ''"> 
              <xsl:text> - </xsl:text> <!-- hyphen --> 
              <xsl:value-of select="key('ClsKey',@Id_num)/@TransferTitle"/>
            </xsl:if>
            <xsl:if test="normalize-space(key('ClsKey',@Id_num)/@Transfer_school) != ''"> 
              <xsl:text> - </xsl:text> <!-- hyphen --> 
              <xsl:value-of select="key('ClsKey',@Id_num)/@Transfer_school"/>
            </xsl:if>
         </td>
      </tr>
      </xsl:if>
   </xsl:for-each>
   </xsl:if> <!-- show-course-keys-only = N -->

    <xsl:if test="$vShowCourseSignals='Y'">
    <tr>
   <td colspan="20">
    <xsl:call-template name="tCourseSignalsHelp" />
   </td>
   </tr>
   </xsl:if>

   </table>
</xsl:if>
</xsl:for-each> 
</xsl:template>

<!-- CourseSignals grade or icon -->
<xsl:template name="tCourseSignalsGrade">
  <xsl:choose>
  <xsl:when test="$vShowCourseSignals='Y'">  <!-- CourseSignals -->
    <xsl:choose>
    <!-- Effort - contains both the color and the high/low value -->
    <xsl:when test="key('ClsKey',@Id_num)[@In_progress='Y']/Attribute[@Code='SIGNALEFFORT' and @Value='6']">
     <img src="common/coursesignals-red.png" ondragstart="window.event.returnValue=false;">
        <xsl:attribute name="title"><xsl:copy-of select="$CourseSignalsRedLow"/></xsl:attribute>
     </img>
    </xsl:when>
    <xsl:when test="key('ClsKey',@Id_num)[@In_progress='Y']/Attribute[@Code='SIGNALEFFORT' and @Value='5']">
     <img src="common/coursesignals-red.png" ondragstart="window.event.returnValue=false;">
        <xsl:attribute name="title"><xsl:copy-of select="$CourseSignalsRedHigh"/></xsl:attribute>
     </img>
    </xsl:when>
    <xsl:when test="key('ClsKey',@Id_num)[@In_progress='Y']/Attribute[@Code='SIGNALEFFORT' and @Value='4']">
     <img src="common/coursesignals-yellow.png" ondragstart="window.event.returnValue=false;">
        <xsl:attribute name="title"><xsl:copy-of select="$CourseSignalsYellowLow"/></xsl:attribute>
     </img>
    </xsl:when>
    <xsl:when test="key('ClsKey',@Id_num)[@In_progress='Y']/Attribute[@Code='SIGNALEFFORT' and @Value='3']">
     <img src="common/coursesignals-yellow.png" ondragstart="window.event.returnValue=false;">
        <xsl:attribute name="title"><xsl:copy-of select="$CourseSignalsYellowHigh"/></xsl:attribute>
     </img>
    </xsl:when>
    <xsl:when test="key('ClsKey',@Id_num)[@In_progress='Y']/Attribute[@Code='SIGNALEFFORT' and @Value='2']">
     <img src="common/coursesignals-green.png" ondragstart="window.event.returnValue=false;">
        <xsl:attribute name="title"><xsl:copy-of select="$CourseSignalsGreenLow"/></xsl:attribute>
     </img>
    </xsl:when>
    <xsl:when test="key('ClsKey',@Id_num)[@In_progress='Y']/Attribute[@Code='SIGNALEFFORT' and @Value='1']">
     <img src="common/coursesignals-green.png" ondragstart="window.event.returnValue=false;">
        <xsl:attribute name="title"><xsl:copy-of select="$CourseSignalsGreenHigh"/></xsl:attribute>
     </img>
    </xsl:when>
    <!-- Effort is missing so just rely on the signal color -->
    <xsl:when test="key('ClsKey',@Id_num)[@In_progress='Y']/Attribute[@Code='COURSESIGNAL' and @Value='RED']">
     <img src="common/coursesignals-red.png" ondragstart="window.event.returnValue=false;">
        <xsl:attribute name="title"><xsl:copy-of select="$CourseSignalsRedHigh"/></xsl:attribute>
     </img>
    </xsl:when>
    <xsl:when test="key('ClsKey',@Id_num)[@In_progress='Y']/Attribute[@Code='COURSESIGNAL' and @Value='YELLOW']">
     <img src="common/coursesignals-yellow.png" ondragstart="window.event.returnValue=false;">
        <xsl:attribute name="title"><xsl:copy-of select="$CourseSignalsYellowHigh"/></xsl:attribute>
     </img>
    </xsl:when>
    <xsl:when test="key('ClsKey',@Id_num)[@In_progress='Y']/Attribute[@Code='COURSESIGNAL' and @Value='GREEN']">
     <img src="common/coursesignals-green.png" ondragstart="window.event.returnValue=false;">
        <xsl:attribute name="title"><xsl:copy-of select="$CourseSignalsGreenHigh"/></xsl:attribute>
     </img>
    </xsl:when>

    <xsl:otherwise> <!-- no signal on this class - just show the grade -->
     <xsl:value-of select="@Letter_grade"/> 
     <xsl:text>&#160;</xsl:text> <!-- space --> 
    </xsl:otherwise>
    </xsl:choose>
  </xsl:when>
  <xsl:otherwise> <!-- CourseSignals is turned off - just how the grade -->
    <xsl:value-of select="@Letter_grade"/> 
    <xsl:text>&#160;</xsl:text> <!-- space --> 
  </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- CourseSignals help link -->
<!-- Only appears if the student has at least one red signal for an in-progress class -->
<xsl:template name="tCourseSignalsHelp">
  <xsl:if test="$vShowCourseSignals='Y'">  <!-- CourseSignals -->
       <xsl:if test="/Report/Audit/Clsinfo/Class[@In_progress='Y']/Attribute[@Code='COURSESIGNAL' and @Value='RED']">
         <table border="0" cellspacing="0" cellpadding="0" width="80%" class="bgLight0" align="center">
          <tr>
           <td rowspan="20" colspan="20" align="center">
               <img src="common/coursesignals-red.png" title="You should seek help" ondragstart="window.event.returnValue=false;"/>
           </td>
          </tr>
         <tr >
            <td class="bgLight0" colspan="1" rowspan="2" valign="middle" xxnowrap="false" align="center">
               &#160;You are having trouble with your classes this semester. 
               We encourage you to make use of the services on campus to help you succeed.
               Please review the many ways we can help you by visiting 
               <a title="Get help" target="newCourseSignalsWindow">
                    <xsl:attribute name="href"><xsl:copy-of select="$CourseSignalsHelpUrl"/></xsl:attribute>
                    <xsl:copy-of select="$CourseSignalsHelpUrl"/>
               </a>
            </td>
            <!-- <td align="right" width="10%">          </td> -->
         </tr>
         </table>
      </xsl:if> <!-- help link -->
  </xsl:if> <!-- if-coursesignals -->
</xsl:template>

<xsl:template name="tSectionExceptions">
<table border="0" cellspacing="1" cellpadding="0" width="100%" class="Blocks">
   <tr>
      <td colspan="20">
      <table border="0" cellspacing="0" cellpadding="0" width="100%" class="BlockHeader">
         <tr >
            <td class="BlockHeader" colspan="1" rowspan="2" valign="middle" nowrap="true">
               &#160;Exceptions
            </td>
         </tr>
      </table>
      </td>
   </tr>
   <tr >
   <td class="ExceptionHeader">Type       </td>  
   <td class="ExceptionHeader">Description</td>  
   <td class="ExceptionHeader">Date       </td>  
   <td class="ExceptionHeader">Who        </td>  
   <td class="ExceptionHeader">Block      </td>  
   <td class="ExceptionHeader">Enforced   </td>  
   </tr>

   <xsl:for-each select="ExceptionList/Exception">
   <tr>
        <xsl:if test="position() mod 2 = 0">
         <xsl:attribute name="class">CourseAppliedRowAlt</xsl:attribute>
        </xsl:if>
        <xsl:if test="position() mod 2 = 1">
         <xsl:attribute name="class">CourseAppliedRowWhite</xsl:attribute>
        </xsl:if>
      <td class="AuditExceptionData">
         <xsl:call-template name="tExceptionType"/>
      </td>  
      <td class="AuditExceptionData">
         <!-- Label and Details -->
         <!-- Show the Details as a hint on the label - but only for non-students -->
         <xsl:choose> 
         <xsl:when test="/Report/@rptUsersId != /Report/Audit/AuditHeader/@Stu_id and 
                         normalize-space(@Details) != '' "> 
         <a> 
          <xsl:attribute name="title"><xsl:value-of select="@Details"/></xsl:attribute>
          <xsl:value-of select="@Label"/>
         </a>  
         </xsl:when> 
         <xsl:otherwise> <!-- don't show a link -->
          <xsl:value-of select="@Label"/>
         </xsl:otherwise> 
         </xsl:choose>
      </td>
      <td class="AuditExceptionData"><!-- xsl:value-of select="@Date"/ -->
         <xsl:call-template name="FormatXptDate"/>
      </td>
      <td class="AuditExceptionData">
         <xsl:value-of select="@Who"/>
      </td>
      <!-- <td><xsl:value-of select="Id_num"/></td>      -->
      <td class="AuditExceptionData">
         <xsl:value-of select="@Req_id"/>
      </td>
      <!-- <td><xsl:value-of select="Node_type"/></td>  -->
      <!-- <td><xsl:value-of select="Node_id"/></td>    -->
      <td class="AuditExceptionData">
          <xsl:if test="@Enforced = 'No'">
           <a> 
            <xsl:attribute name="title"><xsl:value-of select="@Reason"/></xsl:attribute>
            <xsl:value-of select="@Enforced"/>
          </a> 
          </xsl:if>
          <xsl:if test="@Enforced != 'No'">
            <xsl:value-of select="@Enforced"/>
          </xsl:if>
      </td>
      <!-- <td><xsl:value-of select="School"/></td>     -->
      <!-- <td><xsl:value-of select="Degree"/></td>     -->
      <!-- <td><xsl:value-of select="Status"/></td>     -->
      <!-- <td><xsl:value-of select="Text"/></td>       -->

      <!-- <td><xsl:value-of select="Note_num"/></td> -->
      <!-- <td><xsl:value-of select="User_last"/></td> -->
   </tr>
   </xsl:for-each>
</table>
</xsl:template>

<xsl:template name="tSectionNotes">
   <br/>
   <table border="0" cellspacing="1" cellpadding="0" width="100%" class="Blocks">
      <tr>
      <td colspan="20">
      <table border="0" cellspacing="0" cellpadding="0" width="100%" class="BlockHeader">
         <tr >
            <td class="BlockHeader" colspan="1" rowspan="2" valign="middle" nowrap="true">
               &#160;Notes
            </td>
         </tr>
      </table>
      </td>
      </tr>
      <tr>
            <!-- If this school uses the internal-note checkbox and this is not a student reviewing their own audit -->
            <xsl:if test="(/Report/@rptShowNoteCheckbox) ='Y' and /Report/@rptUsersId != /Report/Audit/AuditHeader/@Stu_id"> 
          <td class="AuditNotesHeader"><b>Internal</b></td>  
            </xsl:if>
         <td class="AuditNotesHeader" width="70%"><b> </b></td>  
         <td class="AuditNotesHeader"><b> Entered by  </b></td>  
         <td class="AuditNotesHeader"><b> Date </b></td>  
      </tr>

      <xsl:for-each select="Notes/Note[@Note_type != 'PL']">
        <xsl:choose>
      <xsl:when test="$vShowPetitions='N' and substring(@Note_status, 1, 1) = 'P'" >
          <!-- do not show this petition -->
       </xsl:when>
       <xsl:otherwise> <!-- show this normal note or petition -->
      <tr>
        <xsl:if test="position() mod 2 = 0">
         <xsl:attribute name="class">CourseAppliedRowAlt</xsl:attribute>
        </xsl:if>
        <xsl:if test="position() mod 2 = 1">
         <xsl:attribute name="class">CourseAppliedRowWhite</xsl:attribute>
        </xsl:if>
            <!-- Internal flag -->
            <xsl:if test="(/Report/@rptShowNoteCheckbox) ='Y' and /Report/@rptUsersId != /Report/Audit/AuditHeader/@Stu_id"> 
          <td align="center">
              <xsl:choose>
              <xsl:when test="substring(@Note_type,2,1)='I'"> <!-- Internal -->
                <img src="common/internal-note-checkmark.gif" ondragstart="window.event.returnValue=false;"
                     title="This note is marked as 'Internal - not available to the student' " border="0"/>
              </xsl:when>
              <xsl:otherwise>
                &#160;
              </xsl:otherwise>
              </xsl:choose>
          </td>  
            </xsl:if>

         <td class="AuditNotesData">
         <xsl:for-each select="./Text"><xsl:value-of select="."/></xsl:for-each>          
         </td>  
         <td class="AuditNotesData"><!-- xsl:value-of select="@Note_date"/ -->
            <xsl:value-of select="@Note_who"/>
         </td>
         <td class="AuditNotesData">
            <xsl:call-template name="FormatNoteDate"/>
         </td>
      </tr>
       </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
   </table>

</xsl:template>


<xsl:template name="tExceptionType">
           <xsl:choose>
            <xsl:when test="@Type = 'AH'">  
            Apply Here
            </xsl:when>
            <xsl:when test="@Type = 'AA'">  
            Also Allow
            </xsl:when>
            <xsl:when test="@Type = 'FC'">  
            Force Complete
            </xsl:when>
            <xsl:when test="@Type = 'RR'">  
            Substitution
            </xsl:when>
            <xsl:when test="@Type = 'NN'">  
            Remove Course / Change the Limit
            </xsl:when>
            <xsl:otherwise>
           Unknown
            </xsl:otherwise>
          </xsl:choose>
</xsl:template>

<!-- template tIndentLevel-Advice removed - not used 1.15 -->

<xsl:template name="tStudentID"> 
<xsl:variable name="stu_id"           select="normalize-space(AuditHeader/@Stu_id)"/>
<xsl:variable name="stu_id_length"    select="string-length(normalize-space(AuditHeader/@Stu_id))"/>
<xsl:variable name="fill_asterisks"   select="$stu_id_length"/>
<xsl:variable name="bytes_to_remove"  select="/Report/@rptCFG020MaskStudentID"/>

<xsl:variable name="bytes_to_show"    select="$stu_id_length - $bytes_to_remove"/>
<xsl:variable name="myAsterisks">
<xsl:call-template name="tAsterisks" >
   <xsl:with-param name="bytes_to_remove" select="$bytes_to_remove" />
</xsl:call-template>
</xsl:variable>

<xsl:variable name="formatted_stu_id" />
<xsl:choose>
   <xsl:when test="/Report/@rptCFG020MaskStudentID = 'A'">  
      <xsl:call-template name="tFillAsterisks" >
         <xsl:with-param name="string_length" select="$fill_asterisks" />
      </xsl:call-template>
   </xsl:when>
   <xsl:when test="/Report/@rptCFG020MaskStudentID = 'N'">  
      <xsl:value-of select="AuditHeader/@Stu_id"/>
   </xsl:when>
   <xsl:otherwise>
      <xsl:value-of select="concat($myAsterisks, substring($stu_id, $bytes_to_remove + 1, $bytes_to_show))" />
   </xsl:otherwise>
</xsl:choose>

</xsl:template>

<!-- tBlocks template contains the block/rule templates -->
<xsl:include href="AuditBlocks.xsl" />

<!-- tLegend template is in this included xsl; shared by athletic and academic audits -->
<xsl:include href="AuditLegend.xsl" />

<!-- tStudentHeader template is in this included xsl; shared by athletic and fin-aid audits -->
<xsl:include href="AuditStudentHeader.xsl" />

<!-- FormatDate template is in this included xsl -->
<xsl:include href="FormatDate.xsl" />

<!--
<xsl:template name="tFormatNumber">
<xsl:template name="FormatRuleXptDate">   
<xsl:template name="FormatXptDate"> 
<xsl:template name="FormatNoteDate">   
<xsl:template name="globalReplace">
<xsl:template name="tFillAsterisks">
<xsl:template name="tAsterisks">
-->
<!-- Templates for general functionality -->
<xsl:include href="CommonTemplates.xsl" />

</xsl:stylesheet>
