<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:mets="http://www.loc.gov/METS/"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:mcr="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:encoder="xalan://java.net.URLEncoder"
  exclude-result-prefixes="mcr encoder"
  version="1.0">
  <xsl:output method="xml" encoding="utf-8" />
  <xsl:param name="MCR.Module-iview2.SupportedContentTypes" />
  <xsl:param name="WebApplicationBaseURL" />
  <xsl:param name="WebApplicationServletsURL" select="concat($WebApplicationBaseURL, 'servlets/')" />
  <xsl:param name="derivateID" select="substring-after(/mets:mets/mets:dmdSec/@ID,'_')" />
  <xsl:param name="MCR.Viewer.PDFCreatorURI" />

  <xsl:key name="logDiv" match="mets:div" use="@ID" />

  <xsl:param name="objectID" />
  <!-- this is where the master file group is located (files that are referenced by a relative URL) -->
  <xsl:variable name="masterFileGrp"
                select="/mets:mets/mets:fileSec/mets:fileGrp[
      @USE='MASTER' and
      mets:file/mets:FLocat/@LOCTYPE='URL' and
      not(
        contains(mets:file/mets:FLocat/@xlink:href , '://')
      )
    ]" />

  <!-- - - - - - - - - Identity Transformation - - - - - - - - - -->
  <xsl:template match='@*|node()'>
    <xsl:copy>
      <xsl:apply-templates select='@*|node()' />
    </xsl:copy>
  </xsl:template>


  <xsl:template match="mets:fileSec">
    <xsl:copy>
      <xsl:copy-of select="@*" />
      <xsl:call-template name="generateIViewURLS">
        <xsl:with-param name="use" select="'THUMBS'" />
      </xsl:call-template>
      <xsl:call-template name="generateIViewURLS">
        <xsl:with-param name="use" select="'DEFAULT'" />
        <xsl:with-param name="zoom" select="'MAX'" />
      </xsl:call-template>
      <xsl:call-template name="generateIViewURLS">
        <xsl:with-param name="use" select="'VIEWER'" />
      </xsl:call-template>
      <xsl:call-template name="generateIViewURLS">
        <xsl:with-param name="use" select="'IDENTIFIERS'" />
      </xsl:call-template>
      <!-- only use download when pdf creator is set -->
      <xsl:if test="$MCR.Viewer.PDFCreatorURI">
        <xsl:call-template name="generateIViewURLS">
          <xsl:with-param name="use" select="'DOWNLOAD'" />
        </xsl:call-template>
      </xsl:if>
      <xsl:apply-templates mode="replaceURL" select="$copyFileGrp" />
    </xsl:copy>

  </xsl:template>

  <!-- Copy the Groups, but replace URL with absolute -->
  <xsl:template match="@*|node()" mode="replaceURL">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="replaceURL" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mets:FLocat[@LOCTYPE='URL']" mode="replaceURL">
    <xsl:variable name="absoluteLocation">
      <xsl:value-of select="concat($WebApplicationServletsURL, 'MCRDerivateContentTransformerServlet/', $derivateID, '/', @xlink:href)" />
    </xsl:variable>
    <mets:FLocat LOCTYPE="URL" xlink:href="{$absoluteLocation}" />
  </xsl:template>

  <xsl:template match="mets:smLink">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
    <xsl:call-template name="traverseSmLink">
      <xsl:with-param name="from" select="@xlink:from" />
      <xsl:with-param name="to" select="@xlink:to" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="traverseSmLink">
    <xsl:param name="from" />
    <xsl:param name="to" />
    <xsl:variable name="logDiv" select="key('logDiv', $from)/parent::mets:div/@ID" />
    <xsl:if test="$logDiv">
      <mets:smLink xlink:from="{$logDiv}" xlink:to="{$to}" />
      <xsl:call-template name="traverseSmLink">
        <xsl:with-param name="from" select="$logDiv" />
        <xsl:with-param name="to" select="$to" />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>


  <xsl:template name="generateIViewURLS">
    <xsl:param name="use" />
    <xsl:param name="zoom" select="''" />
    <xsl:comment>
      <xsl:value-of select="concat('Start - generateIViewURLS - USE=',$use)" />
    </xsl:comment>
    <mets:fileGrp USE="{$use}">
      <xsl:for-each select="$masterFileGrp/mets:file">
        <xsl:variable name="ncName">
          <xsl:choose>
            <xsl:when test="contains(@ID,'_')">
              <xsl:value-of select="substring-after(@ID,'_')" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="@ID" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$use='THUMBS'">
            <mets:file ID="{concat($use,'_',$ncName)}" MIMETYPE="image/png">
              <mets:FLocat LOCTYPE="URL" xlink:href="{concat($ThumbnailBaseURL,$derivateID,'/',mets:FLocat/@xlink:href)}" />
            </mets:file>
          </xsl:when>
          <xsl:when test="$use='VIEWER'">
            <mets:file ID="{concat($use,'_',$ncName)}" MIMETYPE="text/html">
              <mets:FLocat LOCTYPE="URL" xlink:href="{concat($WebApplicationBaseURL, 'rsc/viewer/', $derivateID, '/', mets:FLocat/@xlink:href)}" />
            </mets:file>
          </xsl:when>
          <xsl:when test="$use='IDENTIFIERS'">
            <mets:file ID="{concat($use,'_',$ncName)}" MIMETYPE="text/html">
              <mets:FLocat LOCTYPE="OTHER" xlink:href="{concat($derivateID, '/', mets:FLocat/@xlink:href)}" />
            </mets:file>
          </xsl:when>
          <xsl:when test="$use='DOWNLOAD' and $MCR.Viewer.PDFCreatorURI">
            <mets:file ID="{concat($use,'_',$ncName)}" MIMETYPE="application/pdf">
              <mets:FLocat LOCTYPE="URL"
                           xlink:href="{concat($WebApplicationBaseURL, 'rsc/pdf', '/',$derivateID, '?pages=', position())}" />
            </mets:file>
          </xsl:when>
          <xsl:otherwise>
            <mets:file ID="{concat($use,'_',$ncName)}" MIMETYPE="image/jpeg">
              <mets:FLocat LOCTYPE="URL" xlink:href="{concat($ImageBaseURL,$zoom,'/',$derivateID,'/',mets:FLocat/@xlink:href)}" />
            </mets:file>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </mets:fileGrp>
    <xsl:comment>
      <xsl:value-of select="concat('End - generateIViewURLS - USE=',$use)" />
    </xsl:comment>
  </xsl:template>

  <xsl:template match="mets:div[$masterFileGrp/mets:file/@ID=mets:fptr/@FILEID]">
    <xsl:copy>
      <xsl:copy-of select="@*" />
      <xsl:attribute name="ORDER">
        <xsl:value-of select="count(preceding-sibling::mets:div)+1" />
      </xsl:attribute>

      <xsl:variable name="fileID" select="mets:fptr[$masterFileGrp/mets:file/@ID=@FILEID]/@FILEID" />
      <xsl:variable name="file" select="$masterFileGrp/mets:file[@ID=$fileID]/mets:FLocat/@xlink:href" />
      <xsl:variable name="filePath">
        <!-- remove leading "./" from relative URL if present -->
        <xsl:choose>
          <xsl:when test="substring($file, 1, 2) = './'">
            <xsl:value-of select="substring($file, 3)" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$file" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="ncName">
        <xsl:choose>
          <xsl:when test="contains($fileID,'_')">
            <xsl:value-of select="substring-after($fileID,'_')" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$fileID" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <mets:fptr FILEID="{concat('DEFAULT_',$ncName)}" />
      <mets:fptr FILEID="{concat('THUMBS_',$ncName)}" />

      <mets:fptr FILEID="{concat('VIEWER_',$ncName)}" />
      <mets:fptr FILEID="{concat('IDENTIFIERS_',$ncName)}" />

      <xsl:if test="$MCR.Viewer.PDFCreatorURI">
        <mets:fptr FILEID="{concat('DOWNLOAD_',$ncName)}" />
      </xsl:if>

      <xsl:if test="mets:fptr[$copyFileGrp/mets:fileGrp/mets:file/@ID=@FILEID]">
        <!-- Copy fptr that have match in copyFileGrp -->
        <xsl:copy-of select="mets:fptr[$copyFileGrp/mets:fileGrp/mets:file/@ID=@FILEID]" />
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mets:structMap[@TYPE='LOGICAL']/mets:div">
    <xsl:copy>
      <xsl:attribute name="DMDID">
        <xsl:value-of select="concat('dmd_', $derivateID)"/>
      </xsl:attribute>
      <xsl:attribute name="ADMID">
        <xsl:value-of select="concat('amd_', $derivateID)"/>
      </xsl:attribute>
      <xsl:apply-templates select="@*|node()" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
