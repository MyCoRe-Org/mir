<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet  version="1.0"
  xmlns:ds="https://dissem.in/deposit/terms/"
  xmlns:mcrlangdetect="xalan://org.mycore.common.MCRLanguageDetector"
  xmlns:mets="http://www.loc.gov/METS/"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="ds mcrlangdetect mets mods xalan">

  <xsl:param name="MIR.Dissemin.Note.Type.Note" select="'dissemin'"/>
  <xsl:param name="MIR.Dissemin.Note.Type.Affiliation" select="'affiliation'"/>
  <xsl:param name="MIR.Dissemin.Note.Type.UploadType" select="'uploadType'"/>

  <xsl:template match='@*|node()'>
    <xsl:param name="ID"/>
    <!-- default template: just copy -->
    <xsl:copy>
      <xsl:apply-templates select='@*|node()'/>
      <xsl:if test="$ID">
        <xsl:attribute name="ID">
          <xsl:value-of select="$ID"/>
        </xsl:attribute>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="/mets:mets">
    <xsl:apply-templates select="mets:dmdSec/mets:mdWrap/mets:xmlData/mods:mods"/>
  </xsl:template>

  <xsl:template match="mods:mods">
    <xsl:copy>
      <xsl:attribute name="version">3.7</xsl:attribute>
      <xsl:apply-templates/>

      <xsl:variable name="dissemInBlock"
                    select="/mets:mets/mets:amdSec/mets:rightsMD/mets:mdWrap/mets:xmlData/ds:dissemin"/>

      <xsl:call-template name="addLicense">
        <xsl:with-param name="dissemInBlock" select="$dissemInBlock"/>
      </xsl:call-template>

      <xsl:call-template name="addRecordInfo">
        <xsl:with-param name="dissemInBlock" select="$dissemInBlock"/>
      </xsl:call-template>

      <xsl:call-template name="addNote">
        <xsl:with-param name="dissemInBlock" select="$dissemInBlock"/>
      </xsl:call-template>

      <xsl:call-template name="addUploadType">
        <xsl:with-param name="dissemInBlock" select="$dissemInBlock"/>
      </xsl:call-template>

      <xsl:call-template name="addAffiliation">
        <xsl:with-param name="dissemInBlock" select="$dissemInBlock"/>
      </xsl:call-template>
    </xsl:copy>
  </xsl:template>

  <xsl:template name="addUploadType">
    <xsl:param name="dissemInBlock"/>
    <xsl:variable name="uploadTypeText" select="$dissemInBlock/ds:publication/ds:uploadType/text()"/>
    <mods:note type="{$MIR.Dissemin.Note.Type.UploadType}">
      <xsl:value-of select="$uploadTypeText"/>
    </mods:note>
  </xsl:template>

  <xsl:template name="addNote">
    <xsl:param name="dissemInBlock"/>
    <xsl:variable name="noteText" select="$dissemInBlock/ds:publication/ds:otherData/ds:entry[@key='note']/text()"/>
    <mods:note type="{$MIR.Dissemin.Note.Type.Note}">
      <xsl:value-of select="$noteText"/>
    </mods:note>
  </xsl:template>

  <xsl:template name="addAffiliation">
    <xsl:param name="dissemInBlock"/>
    <xsl:variable name="affiliationText"
                  select="$dissemInBlock/ds:publication/ds:otherData/ds:entry[@key='affiliation']/text()"/>
    <mods:note type="{$MIR.Dissemin.Note.Type.Affiliation}">
      <xsl:value-of select="$affiliationText"/>
    </mods:note>
  </xsl:template>

  <xsl:template name="addLicense">
    <xsl:param name="dissemInBlock"/>
    <xsl:variable name="licenceURL" select="$dissemInBlock/ds:publication/ds:license/ds:licenseURI/text()"/>
    <xsl:variable name="licenceTransmitID"
                  select="$dissemInBlock/ds:publication/ds:license/ds:licenseTransmitId/text()"/>
    <xsl:variable name="licenseClass" select="document('classification:metadata:-1:children:mir_licenses')"/>
    <xsl:variable name="licenseID">
      <xsl:variable name="categoriesWithSameLicenseURL"
                    select="$licenseClass/.//category[url/@xlink:href=$licenceURL]"/>
      <xsl:variable name="categoriesWithSameLicenseID" select="$licenseClass/.//category[@ID=$licenceTransmitID]"/>
      <xsl:choose>
        <xsl:when test="count($categoriesWithSameLicenseURL) &gt; 0">
          <xsl:value-of select="$categoriesWithSameLicenseURL/@ID"/>
        </xsl:when>
        <xsl:when test="count($categoriesWithSameLicenseID) &gt; 0">
          <xsl:value-of select="$categoriesWithSameLicenseID/@ID"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <!--select="$licenseClass/.//category[url/@xlink:href=$licenceURL]//>  -->
    <xsl:choose>
      <xsl:when test="string-length($licenseID)&gt;0">
        <mods:accessCondition type="use and reproduction"
                              xlink:href="http://www.mycore.org/classifications/mir_licenses#{$licenseID}"
                              xlink:type="simple"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>Could not find license id for license with url
          <xsl:value-of select="$licenceURL"/>
          or id
          <xsl:value-of select="$licenceTransmitID"/>
          Will use rights_reserved
        </xsl:message>
        <mods:accessCondition type="use and reproduction"
                              xlink:href="http://www.mycore.org/classifications/mir_licenses#rights_reserved"
                              xlink:type="simple"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="addRecordInfo">
    <xsl:param name="dissemInBlock"/>
    <xsl:variable name="dissemInID" select="$dissemInBlock/ds:publication/ds:disseminId/text()"/>
    <xsl:variable name="romeoId" select="$dissemInBlock/ds:publication/ds:romeoId/text()"/>
    <mods:recordInfo>

      <xsl:if test="string-length($romeoId)&gt;0">
        <mods:recordIdentifier source="romeo">
          <xsl:value-of select="$romeoId"/>
        </mods:recordIdentifier>
      </xsl:if>

      <xsl:if test="string-length($dissemInID)&gt;0">
        <mods:recordIdentifier source="dissemin">
          <xsl:value-of select="$dissemInID"/>
        </mods:recordIdentifier>
      </xsl:if>

      <mods:recordOrigin>Deposited by dissem.in converted with dissemin-mods2mycore-mods.xsl</mods:recordOrigin>
    </mods:recordInfo>
  </xsl:template>

  <xsl:template match="mods:titleInfo">
    <xsl:copy>
      <xsl:attribute name="type" namespace="http://www.w3.org/1999/xlink">simple</xsl:attribute>
      <!-- Try to detect the language with the MCRLanguageDetector -->
      <xsl:if test="count(mods:title)&gt;0">
        <xsl:variable name="detected" select="mcrlangdetect:detectLanguage(mods:title/text())"/>
        <xsl:if test="string-length($detected)&gt;0">
          <xsl:attribute name="lang" namespace="http://www.w3.org/XML/1998/namespace">
            <xsl:value-of select="$detected"/>
          </xsl:attribute>
        </xsl:if>
      </xsl:if>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mods:relatedItem">
    <xsl:copy>
      <xsl:attribute name="type">original</xsl:attribute>
      <xsl:attribute name="type" namespace="http://www.w3.org/1999/xlink">simple</xsl:attribute>
      <!-- guess the genre if not present -->
      <xsl:if test="not(mods:genre)">
        <xsl:variable name="parentGenre">
          <xsl:choose>
            <xsl:when test="../mods:genre/text()='book-chapter'">book</xsl:when>
            <xsl:when test="../mods:genre/text()='journal-article'">journal</xsl:when>
            <xsl:when test="../mods:genre/text()='journal-issue'">journal</xsl:when>
            <xsl:when test="../mods:genre/text()='proceedings-article'">proceedings</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:if test="string-length($parentGenre)&gt;0">
          <mods:genre type="intern" authorityURI="http://www.mycore.org/classifications/mir_genres"
                      valueURI="http://www.mycore.org/classifications/mir_genres#{$parentGenre}"/>
        </xsl:if>
      </xsl:if>

      <xsl:apply-templates/>
    </xsl:copy>

  </xsl:template>


  <xsl:template match="mods:genre">
    <xsl:variable name="genre">
      <xsl:choose>
        <xsl:when test="text()='book'">book</xsl:when>
        <xsl:when test="text()='book-chapter'">chapter</xsl:when>
        <xsl:when test="text()='journal-article'">article</xsl:when>
        <xsl:when test="text()='journal-issue'">issue</xsl:when>
        <xsl:when test="text()='poster'">poster</xsl:when>
        <xsl:when test="text()='proceedings'">proceedings</xsl:when>
        <xsl:when test="text()='report'">report</xsl:when>
        <xsl:when test="text()='thesis'">thesis</xsl:when>
        <xsl:when test="text()='proceedings-article'">article</xsl:when>
        <xsl:when test="text()='preprint'">article</xsl:when>
        <!--<xsl:when test="text()='other'"></xsl:when>-->
        <!--<xsl:when test="text()='dataset'"></xsl:when>-->
        <!--<xsl:when test="text()='reference-entry'"></xsl:when>-->
        <xsl:otherwise><xsl:message terminate="yes">Could not detect the right genre for <xsl:value-of select="text()" /></xsl:message> </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="string-length($genre) &gt; 0">
      <mods:genre type="intern" authorityURI="http://www.mycore.org/classifications/mir_genres"
                  valueURI="http://www.mycore.org/classifications/mir_genres#{$genre}"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mods:originInfo[not(@eventType)]">
    <mods:originInfo eventType="publication">
      <xsl:apply-templates />
    </mods:originInfo>
  </xsl:template>

  <xsl:template match="mods:languageTerm[@type='code' and @authority='rfc3066']">
    <xsl:copy>
      <xsl:attribute name="type">code</xsl:attribute>
      <xsl:attribute name="authority">rfc5646</xsl:attribute>
      <xsl:copy-of select="text()" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
