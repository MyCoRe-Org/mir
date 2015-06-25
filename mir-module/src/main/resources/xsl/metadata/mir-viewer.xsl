<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:mcr="xalan://org.mycore.common.xml.MCRXMLFunctions"
                xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:FilenameUtils="xalan://org.apache.commons.io.FilenameUtils"
                xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
                xmlns:iview2="xalan://org.mycore.iview2.frontend.MCRIView2XSLFunctions"
                xmlns:xalan="http://xml.apache.org/xalan"
                exclude-result-prefixes="xalan i18n mcr mods xlink FilenameUtils iview2 mcrxsl">
  <xsl:import href="xslImport:modsmeta:metadata/mir-viewer.xsl"/>
  <xsl:param name="UserAgent" />

  <xsl:template match="/">
    <xsl:if test="mycoreobject/structure/derobjects/derobject[key('rights', @xlink:href)/@read]">
      <div id="mir-viewer">
        <xsl:variable name="viewerNodesTmp">
          <div class="row">
            <div class="col-md-12">
              <h3 class="mir-viewer">Vorschau</h3>
              <!-- show one viewer for each derivate -->
              <xsl:for-each select="mycoreobject/structure/derobjects/derobject[key('rights', @xlink:href)/@read]">
                <xsl:call-template name="createViewer"/>
              </xsl:for-each>
            </div>
          </div>
        </xsl:variable>

        <xsl:variable name="viewerNodes" select="xalan:nodeset($viewerNodesTmp)"/>

        <xsl:call-template name="addScripts">
          <xsl:with-param name="generatedNodes" select="$viewerNodes"/>
        </xsl:call-template>

        <xsl:copy-of select="$viewerNodes"/>
      </div>
    </xsl:if>
    <xsl:apply-imports/>
  </xsl:template>

  <xsl:template name="createViewer">
    <xsl:variable name="derId" select="@xlink:href"/>
    <xsl:variable name="derivateXML" select="document(concat('mcrobject:',$derId))"/>
    <xsl:variable name="viewerId" select="concat('viewer_',$derId)"/>

    <xsl:variable name="mainFile" select="$derivateXML/mycorederivate/derivate/internals/internal/@maindoc"/>
    <xsl:variable name="fileNameExtension" select="FilenameUtils:getExtension($mainFile)"/>
    <xsl:choose>
      <xsl:when test="iview2:getSupportedMainFile($derId)">
        <!-- The file will be displayed with mets -->
        <xsl:call-template name="createMetsViewer">
          <xsl:with-param name="WebApplicationBaseURL" select="$WebApplicationBaseURL"/>
          <xsl:with-param name="derId" select="$derId"/>
          <xsl:with-param name="mainFile" select="$mainFile"/>
          <xsl:with-param name="viewerId" select="$viewerId"/>
        </xsl:call-template>
        <xsl:call-template name="createViewerContainer">
          <xsl:with-param name="viewerId" select="$viewerId"/>
          <xsl:with-param name="viewerType" select="'mets'"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$fileNameExtension = 'pdf' and not(mcrxsl:isMobileDevice($UserAgent))">
        <!-- The file will be displayed with pdf.js -->
        <xsl:call-template name="createPDFViewer">
          <xsl:with-param name="WebApplicationBaseURL" select="$WebApplicationBaseURL"/>
          <xsl:with-param name="derId" select="$derId"/>
          <xsl:with-param name="mainFile" select="$mainFile"/>
          <xsl:with-param name="viewerId" select="$viewerId"/>
        </xsl:call-template>
        <xsl:call-template name="createViewerContainer">
          <xsl:with-param name="viewerId" select="$viewerId"/>
          <xsl:with-param name="viewerType" select="'pdf'"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <!-- The file cannot be displayed -->
        <xsl:comment>The Viewer doesnt support the file
          <xsl:value-of select="$mainFile"/>
        </xsl:comment>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="createMetsViewer">
    <xsl:param name="WebApplicationBaseURL"/>
    <xsl:param name="derId"/>
    <xsl:param name="mainFile"/>
    <xsl:param name="viewerId"/>
    <xsl:variable name="metsServletURL"
                  select="concat($WebApplicationBaseURL,'servlets/MCRMETSServlet/', $derId)"/>
    <xsl:variable name="i18nURL"
                  select="concat($WebApplicationBaseURL,'servlets/MCRLocaleServlet/{lang}/component.iview2.*')"/>
    <xsl:variable name="tileURL" select="concat($WebApplicationBaseURL,'servlets/MCRTileServlet/')"/>
    <xsl:variable name="derivateURL"
                  select="concat($WebApplicationBaseURL, 'servlets/MCRFileNodeServlet/', $derId)"/>
    <xsl:variable name="doctype" select="'mets'"/>

    <script>
      window.addEventListener("load", function(){
      new mycore.viewer.MyCoReViewer(jQuery('<xsl:value-of select="concat('#',$viewerId)"/>'), {
      /* http://archive.thulb.uni-jena.de/hisbest is the path to the MyCoRe instance */
      "derivateURL": "<xsl:value-of select="$derivateURL"/>",
      "metsURL": "<xsl:value-of select="$metsServletURL"/>",
      "i18nURL": "<xsl:value-of select="$i18nURL"/>",
      "derivate": "<xsl:value-of select="$derId"/>",
      "filePath": "<xsl:value-of select="$mainFile"/>",
      "mobile": false,
      "tileProviderPath": "<xsl:value-of select="$tileURL"/>",
      "imageXmlPath": "<xsl:value-of select="$tileURL"/>",
      "doctype": "<xsl:value-of select="$doctype"/>",
      "webApplicationBaseURL": "<xsl:value-of select="$WebApplicationBaseURL"/>",
      "lang": "de",
      chapter: {
      enabled: true,
      showOnStart: false
      },
      permalink: {
      enabled: true,
      updateHistory: false
      }});
      });
    </script>
  </xsl:template>

  <xsl:template name="createPDFViewer">
    <xsl:param name="WebApplicationBaseURL"/>
    <xsl:param name="derId"/>
    <xsl:param name="mainFile"/>
    <xsl:param name="viewerId"/>

    <xsl:variable name="i18nURL"
                  select="concat($WebApplicationBaseURL,'servlets/MCRLocaleServlet/{lang}/component.iview2.*')"/>
    <xsl:variable name="derivateURL"
                  select="concat($WebApplicationBaseURL, 'servlets/MCRFileNodeServlet/', $derId)"/>
    <xsl:variable name="pdfWorkerURL" select="concat($WebApplicationBaseURL, 'modules/iview2/js/lib/pdf.worker.js')"/>
    <xsl:variable name="pdfProviderURL"
                  select="concat($WebApplicationBaseURL,'servlets/MCRFileNodeServlet/{derivate}/{filePath}')"/>
    <xsl:variable name="doctype" select="'pdf'"/>
    <script>
      window.addEventListener("load", function(){

      new mycore.viewer.MyCoReViewer(jQuery('<xsl:value-of select="concat('#',$viewerId)"/>'), {
      /* http://archive.thulb.uni-jena.de/hisbest is the path to the MyCoRe instance */
      "derivateURL": "<xsl:value-of select="$derivateURL"/>",
      "i18nURL": "<xsl:value-of select="$i18nURL"/>",
      "derivate": "<xsl:value-of select="$derId"/>",
      "filePath": "<xsl:value-of select="$mainFile"/>",
      "mobile": false,
      "pdfProviderURL": "<xsl:value-of select="$pdfProviderURL"/>",
      "doctype": "<xsl:value-of select="$doctype"/>",
      "webApplicationBaseURL": "<xsl:value-of select="$WebApplicationBaseURL"/>",
      "pdfWorkerURL": "<xsl:value-of select="$pdfWorkerURL"/>",
      "lang": "de",
      chapter: {
      enabled: true,
      showOnStart: false
      },
      permalink: {
      enabled: true,
      updateHistory: false
      }});
      });
    </script>
  </xsl:template>


  <xsl:template name="createViewerContainer">
    <xsl:param name="viewerId"/>
    <xsl:param name="viewerType"/>

    <div id="{$viewerId}" class="viewer {$viewerType}">
    </div>
  </xsl:template>

  <xsl:template name="addScripts">
    <xsl:param name="generatedNodes"/>

    <xsl:if test="$generatedNodes//div[contains(@class, 'viewer')]">
      <!--There are different modules-->
      <!-- Base contains the basic code of the viewer -->
      <script type="text/javascript"
              src="{concat($WebApplicationBaseURL, 'modules/iview2/js/iview-client-base.js')}"></script>

      <!-- there is also a iview-client-desktop (more functions) -->
      <script type="text/javascript"
              src="{concat($WebApplicationBaseURL, 'modules/iview2/js/iview-client-frame.js')}"></script>

      <link rel="stylesheet" type="text/css"
            href="{concat($WebApplicationBaseURL, 'modules/iview2/css/default.css')}"></link>

      <xsl:if test="$generatedNodes//div[@class= 'viewer mets']">
        <!-- module for loading mets files and iview files.  -->
        <script type="text/javascript"
                src="{concat($WebApplicationBaseURL, 'modules/iview2/js/iview-client-mets.js')}"></script>
      </xsl:if>

      <xsl:if test="$generatedNodes//div[@class= 'viewer pdf']">
        <!-- module for loading pdf files. -->
        <script type="text/javascript"
                src="{concat($WebApplicationBaseURL, 'modules/iview2/js/iview-client-pdf.js')}"></script>

        <!-- pdf.js dependency for mycore-viewer-->
        <script type="text/javascript"
                src="{concat($WebApplicationBaseURL, 'modules/iview2/js/lib/pdf.js')}"></script>
      </xsl:if>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>