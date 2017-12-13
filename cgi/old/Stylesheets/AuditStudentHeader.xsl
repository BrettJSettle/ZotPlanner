<!-- 
 Copyright 1995-2012 Ellucian Company L.P. and its affiliates. 
 $Id: //Tuxedo/RELEASE/Product/webroot/AuditStudentHeader.xsl#2 $ -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"> 

<!-- //////////////////////////////////////////////////////////////////////// -->
<!-- STUDENT HEADER -->
<!-- This template is shared by the academic, athletic and fin-aid worksheets 
     If you have the need, you can use a choose on the AuditType to hide a field
     or to show a different field. 
     It is recommended that all changes be made in this file for all audit types
     instead of creating separate xsl files.
     <xsl:when test="/Report/Audit/AuditHeader/@AuditType = 'FA'"> Financial Aid
     <xsl:when test="/Report/Audit/AuditHeader/@AuditType = 'AE'"> Athletic Eligibility
     <xsl:when test="/Report/Audit/AuditHeader/@AuditType = 'AA'"> Academic Audit
-->
<!-- //////////////////////////////////////////////////////////////////////// -->
<xsl:template name="tStudentHeader"> 

<xsl:for-each select="AuditHeader">
<table border="0" cellspacing="0" cellpadding="0" width="100%" class="AuditTable">

   <tr>                                                                          
      <td align="left" valign="top">                                               
      <table border="0" cellspacing="0" cellpadding="4" width="100%">
         <tr>
            <td align="left" valign="middle" class="StuHead">
            <span class="StuHeadTitle"> <xsl:value-of select="/Report/@rptReportName" /> </span>
            <span class="StuHeadCaption">&#160; &#160;<xsl:value-of select="@Audit_id" /> as of         
                    <xsl:call-template name="FormatDate">
                     <xsl:with-param name="pDate" select="concat(@DateYear,@DateMonth,@DateDay)" />
                    </xsl:call-template>
                 at <!-- Format the time as hh:mm --> <xsl:value-of select="@TimeHour" />:<xsl:value-of select="@TimeMinute" />
            </span>
            </td>
            <!-- Show the audit description and freeze-status -->
            <td align="center" valign="middle" class="StuHead">
            <span class="StuHeadTitle">
             <xsl:value-of select="/Report/Audit/AuditHeader/@AuditDescription" /> 
                 <xsl:if test="/Report/Audit/AuditHeader/@FreezeTypeDescription != ''" > <!-- if frozen -->
              (<xsl:value-of select="/Report/Audit/AuditHeader/@FreezeTypeDescription" />) 
                 </xsl:if> 
            </span>
            </td>
            <td align="right" valign="middle" class="StuHead">
              <!-- This will be "What If Audit" or "Look Ahead Audit"; for normal audits this attribute will not exist -->
              <span class="StuHeadTitle"> <xsl:value-of select="/Report/@rptAuditAction" /> </span>
            <br />
            </td>
            
            <xsl:if test="/Report/@rptReportCode='SEP31' ">
               <td align="right" valign="middle" class="StuHead">
                <span style="font-weight:bold;font-size:9pt">
                <a href="javascript:printForm();void(0);" style="color:white">Print</a>
                </span>
              </td>
           </xsl:if>
         </tr>
      </table>
      </td>
   </tr>

<!-- If we are to show the disclaimer and this is the aid or athletic audit - 
     then show it at the top of the worksheet - instead of at the bottom as in an academic audit -->
<xsl:if test="/Report/@rptShowDisclaimer='Y'">
<xsl:if test="/Report/Audit/AuditHeader/@AuditType = 'FA' or  
              /Report/Audit/AuditHeader/@AuditType = 'AE'    "> 
	<tr>                                                                          
		<td align="left" valign="top">                                               
		<table border="0" cellspacing="0" cellpadding="4" width="100%">
			<tr>
				<td align="left" valign="middle" class="DisclaimerText">
                
					<xsl:if test="/Report/Audit/AuditHeader/AuditType='AA'">
						<xsl:for-each select="document('AuditDisclaimer.xml')">
						<xsl:value-of select="."/>
						</xsl:for-each>
					</xsl:if>

					<xsl:if test="/Report/Audit/AuditHeader/AuditType='FA'">
						<xsl:for-each select="document('AuditDisclaimer_Aid.xml')">
						<xsl:value-of select="."/>
						</xsl:for-each>
					</xsl:if>
		   
					<xsl:if test="/Report/Audit/AuditHeader/AuditType='AE'">
						<xsl:for-each select="document('AuditDisclaimer_Ath.xml')">
						<xsl:value-of select="."/>
						</xsl:for-each>
					</xsl:if>
			
				<br />
				<br />
				</td>
			</tr>
		</table>
		</td>
	</tr>
</xsl:if>
</xsl:if>
      
   <tr>
      <td>
      <table class="Inner" cellspacing="1" cellpadding="3" border="0" width="100%">

  <!-- xxxxxxxxxxx NEXT ROW xxxxxxxxxxx -->
  <tr class="StuTableTitle">
    <td class="StuTableTitle" ><xsl:copy-of select="$vLabelStudentName"/></td>
    <td class="StuTableData" >
      <xsl:if test="/Report/@rptUsersId = /Report/Audit/AuditHeader/@Stu_id"> 
        <xsl:value-of select="/Report/Audit/AuditHeader/@Stu_name" />  
      </xsl:if>
      <!-- Allow user to email the student if this is not the student -->
      <xsl:if test="/Report/@rptUsersId != /Report/Audit/AuditHeader/@Stu_id"> 
        <a>
          <xsl:attribute name="href">mailto:<xsl:value-of select="/Report/Audit/AuditHeader/@Stu_email" 
                 />?subject=Advising Worksheet issue&amp;body=About your worksheet, </xsl:attribute>
          <xsl:attribute name="title">Email this student</xsl:attribute>
          <xsl:value-of select="/Report/Audit/AuditHeader/@Stu_name" />  
        </a>&#160; <!-- space -->  
      </xsl:if>
    </td>
    <td class="StuTableTitle" ><xsl:copy-of select="$vLabelSchool"/></td>
    <td class="StuTableData" ><xsl:value-of select="/Report/Audit/Deginfo/DegreeData/@SchoolLit" />  </td>
  </tr>
  <!-- xxxxxxxxxxx NEXT ROW xxxxxxxxxxx -->
  <tr class="StuTableTitle">
    <td class="StuTableTitle" ><xsl:copy-of select="$vLabelStudentID"/></td>
    <td class="StuTableData"  >  <xsl:for-each select="/Report/Audit"><xsl:call-template name="tStudentID" /> </xsl:for-each></td>
    <td class="StuTableTitle"  ><xsl:copy-of select="$vLabelDegree"/> </td>
    <td class="StuTableData"   ><xsl:value-of select="/Report/Audit/Deginfo/DegreeData/@DegreeLit" /> &#160; <!-- space --> </td>
  </tr>
  <!-- xxxxxxxxxxx NEXT ROW xxxxxxxxxxx -->
  <tr class="StuTableTitle">
      <td class="StuTableTitle" ><xsl:copy-of select="$vLabelLevel"/></td>
      <td class="StuTableData"  >
	<!-- <xsl:value-of select="/Report/Audit/Deginfo/DegreeData/@Stu_levelLit" /> &#160; -->
        <xsl:value-of select="substring(/Report/Audit/Deginfo/DegreeData/@Stu_levelLit, 8, 12)" /> &#160; <!-- space --> 
      </td>
    <td class="StuTableTitle" >
      <xsl:copy-of select="$vLabelCollege"/><xsl:if test="count(/Report/Audit/Deginfo/Goal[@Code='COLLEGE'])>1">s</xsl:if>
   </td>
    <td class="StuTableData"  >
    <xsl:for-each select="/Report/Audit/Deginfo/Goal[@Code='COLLEGE']">
      <xsl:value-of select="@ValueLit" /><xsl:if test="position()!=last()"><br /></xsl:if>
   </xsl:for-each>   
   </td>
  </tr>
  <!-- xxxxxxxxxxx NEXT ROW xxxxxxxxxxx -->
  <tr class="StuTableTitle">
    <!-- Grad App Status -->
    <td class="StuTableTitle"  >
	Grad App Status
   </td>
    <td class="StuTableData"   >
    <xsl:for-each select="/Report/Audit/Deginfo/Report[@Code='GRADAPP']">
	<xsl:value-of select="@Value" /> 
	<xsl:if test="position()!=last()"><br /></xsl:if>
    </xsl:for-each>
    </td>
    <!-- MAJORS -->
    <td class="StuTableTitle" >
      <xsl:copy-of select="$vLabelMajor"/><xsl:if test="count(/Report/Audit/Deginfo/Goal[@Code='MAJOR'])>1">s</xsl:if>
   </td>
    <td class="StuTableData"  >
    <xsl:for-each select="/Report/Audit/Deginfo/Goal[@Code='MAJOR']">
      <xsl:value-of select="@ValueLit" /><xsl:if test="position()!=last()"><br /></xsl:if>
   </xsl:for-each>
   </td>
  </tr>
  <!-- xxxxxxxxxxx NEXT ROW xxxxxxxxxxx -->
  <tr class="StuTableTitle">
    <td class="StuTableTitle" ><xsl:copy-of select="$vLabelOverallGPA"/></td>
    <xsl:choose>
      <xsl:when test="/Report/@rptShowStudentSystemGPA='Y'">
      <!-- If the SSGPA is empty then show the DWGPA value -->
        <xsl:choose>
     <xsl:when test="normalize-space(@SSGPA)=''"> <!-- SSGPA is empty/blanks -->
       <td class="StuTableData"  >
         <xsl:call-template name="tFormatNumber" >
            <xsl:with-param name="iNumber"         select="@DWGPA" />
            <xsl:with-param name="sRoundingMethod" select="$vGPADecimals" />
         </xsl:call-template>
      </td>
     </xsl:when>
     <xsl:otherwise>
       <td class="StuTableData"  >
         <xsl:call-template name="tFormatNumber" >
            <xsl:with-param name="iNumber" select="@SSGPA" />
            <xsl:with-param name="sRoundingMethod" select="$vGPADecimals" />
         </xsl:call-template>
      </td>
     </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise> <!-- We always want to show the DWGPA -->
   <td class="StuTableData"  >
         <xsl:call-template name="tFormatNumber" >
            <xsl:with-param name="iNumber" select="@DWGPA" />
            <xsl:with-param name="sRoundingMethod" select="$vGPADecimals" />
         </xsl:call-template>
   </td>
      </xsl:otherwise>
    </xsl:choose>
    <td class="StuTableTitle" >
      <xsl:copy-of select="$vLabelMinor"/><xsl:if test="count(/Report/Audit/Deginfo/Goal[@Code='MINOR'])>1">s</xsl:if>
   </td>
    <td class="StuTableData"  >
    <xsl:for-each select="/Report/Audit/Deginfo/Goal[@Code='MINOR']">
      <xsl:value-of select="@ValueLit" /><xsl:if test="position()!=last()"><br /></xsl:if>
   </xsl:for-each>
   </td>
    </tr>

  <xsl:if test="/Report/Audit/Deginfo/DegreeData/@DegreeSource='A '" > <!-- Status = Applicant -->
  <!-- xxxxxxxxxxx NEXT ROW xxxxxxxxxxx -->
  <tr class="StuTableTitle">
   <td class="StuTableTitle"        >Status   </td>
   <td class="StuTableDataHighlight">Applicant</td>
   <td class="StuTableTitle" >      <!-- empty -->   </td>
   <td class="StuTableData"  >      <!-- empty -->   </td>
  </tr>
  </xsl:if>

  </table>
   </td></tr>  
</table>
  </xsl:for-each> <!-- audit header -->
</xsl:template> 
<!-- //////////////////////////////////////////////////////////////////////// -->
<!-- STUDENT HEADER END -->
<!-- //////////////////////////////////////////////////////////////////////// -->

</xsl:stylesheet>
