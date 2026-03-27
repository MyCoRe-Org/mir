<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mcrlayoututils="http://www.mycore.de/xslt/layoututils"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:import href="xslImport:modsmeta:metadata/mir-viewer.xsl" />

  <xsl:param name="UserAgent" />
  <xsl:param name="MIR.DFGViewer.enable" select="'false'" />
  <xsl:param name="MCR.Viewer.PDFCreatorURI" />
  <xsl:param name="MCR.Viewer.PDFCreatorStyle" />
  <xsl:param name="MCR.Viewer.PDFCreatorFormatString" />
  <xsl:param name="MCR.Viewer.PDFCreatorRestrictionFormatString" />
  <xsl:param name="WebApplicationBaseURL" />

  <xsl:template match="/">
    <xsl:if test="mycoreobject/structure/derobjects/derobject[mcrxml:isDerivateDisplayEnabled(@xlink:href, 'show-file-viewer')]">
      <div id="mir-viewer">
        <xsl:variable name="viewerNodesTmp">
          <xsl:if test="count(mycoreobject/structure/derobjects/derobject[key('rights', @xlink:href)/@read]) > 0">
            <div class="row mir-preview">
              <div class="col-md-12">
                <h3 class="mir-viewer">
                  <xsl:value-of select="mcri18n:translate('metaData.preview')" />
                </h3>
                <!-- show one viewer for each derivate -->
                <xsl:for-each select="mycoreobject/structure/derobjects/derobject[key('rights', @xlink:href)/@read and mcrxml:isDerivateDisplayEnabled(@xlink:href, 'show-file-viewer')]">
                  <xsl:call-template name="createViewer" />
                </xsl:for-each>
              </div>
            </div>
          </xsl:if>
        </xsl:variable>

        <xsl:variable name="viewerNodes" select="$viewerNodesTmp"/>

        <xsl:if test="$viewerNodes//div[contains(@class, 'viewer')]">
          <xsl:copy-of select="$viewerNodes"/>
        </xsl:if>
      </div>
    </xsl:if>
    <xsl:apply-imports />
  </xsl:template>

  <xsl:template name="createViewer">
    <xsl:variable name="derId" select="@xlink:href" />
    <xsl:variable name="mainFile">
        <xsl:variable name="mainDocName" select="document(concat('callJava:org.mycore.common.xml.MCRXMLFunctions:getMainDocName:',$derId))" />
      <xsl:choose>
        <xsl:when test="starts-with($mainDocName, '/')">
          <xsl:value-of select="$mainDocName" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat('/', $mainDocName)" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="viewerId" select="concat($derId, ':', $mainFile)" />


    <xsl:choose>
      <xsl:when test="string(document(concat('callJava:org.mycore.iview2.services.MCRIView2Tools:getSupportedMainFile:',$derId)))">
        <xsl:choose>
          <xsl:when test="string(document(concat('callJava:org.mycore.iview2.services.MCRIView2Tools:mcriview2tool:',$derId)))">
            <!-- The file will be displayed with mets -->

            <xsl:call-template name="createViewerContainer">
              <xsl:with-param name="viewerId" select="$viewerId" />
              <xsl:with-param name="viewerType" select="'mets'" />
              <xsl:with-param name="derId" select="$derId" />
            </xsl:call-template>
            <xsl:call-template name="loadViewer">
              <xsl:with-param name="derivate" select="$derId" />
              <xsl:with-param name="file" select="$mainFile" />
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <div class="card card-body bg-light no-viewer">
              <xsl:value-of select="mcri18n:translate-with-params('metaData.previewInProcessing', $derId)" />
            </div>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="string(document(concat('callJava:org.mycore.common.xml.MCRXMLFunctions:getMimeType:',$mainFile))) = 'application/pdf' and not(mcrlayoututils:is-mobile-device($UserAgent))">
        <xsl:call-template name="createViewerContainer">
          <xsl:with-param name="viewerId" select="$viewerId" />
          <xsl:with-param name="viewerType" select="'pdf'" />
          <xsl:with-param name="derId" select="$derId" />
        </xsl:call-template>
        <xsl:call-template name="loadViewer">
          <xsl:with-param name="derivate" select="$derId" />
          <xsl:with-param name="file" select="$mainFile" />
        </xsl:call-template>
        <noscript>
          <a href="{$ServletsBaseURL}MCRFileNodeServlet/{$derId}{$mainFile}">
            <xsl:value-of select="$mainFile" />
          </a>
        </noscript>
      </xsl:when>
      <xsl:when test="contains($mainFile, '.epub') and normalize-space(substring-after($mainFile, '.epub')) = ''">
        <xsl:call-template name="createViewerContainer">
          <xsl:with-param name="viewerId" select="$viewerId" />
          <xsl:with-param name="viewerType" select="'epub'" />
          <xsl:with-param name="derId" select="$derId" />
        </xsl:call-template>
        <xsl:call-template name="loadViewer">
          <xsl:with-param name="derivate" select="$derId" />
          <xsl:with-param name="file" select="$mainFile" />
        </xsl:call-template>
        <noscript>
          <a href="{$ServletsBaseURL}MCRFileNodeServlet/{$derId}{$mainFile}">
            <xsl:value-of select="$mainFile" />
          </a>
        </noscript>
      </xsl:when>
      <xsl:otherwise>
        <!-- The file cannot be displayed -->
        <xsl:comment>The Viewer doesnt support the file
          <xsl:value-of select="$mainFile" />
        </xsl:comment>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="loadViewer">
    <xsl:param name="derivate" />
    <xsl:param name="file" />
    <script src="{$WebApplicationBaseURL}rsc/viewer/{$derivate}{iri-to-uri($file)}?embedded=true&amp;XSL.Style=js">
    </script>
  </xsl:template>


  <xsl:template name="createViewerContainer">
    <xsl:param name="viewerId" />
    <xsl:param name="viewerType" />
    <xsl:param name="derId" />

    <div data-viewer="{$viewerId}" class="viewer {$viewerType}">
    </div>

    <xsl:if test="$MIR.DFGViewer.enable='true' and document(concat('org.mycore.iview2.frontend.MCRIView2XSLFunctionsAdapter:hasMETSFile:',$derId))">
      <div class="row">
        <div id="mir-dfgViewer" class="float-end">
          <a title="im DFG-Viewer anzeigen"
             href="{$WebApplicationBaseURL}servlets/MCRDFGLinkServlet?deriv={$derId}"
          >alternativ im<img src="{$WebApplicationBaseURL}images/logo-dfg.png" />-Viewer anzeigen
          </a>
        </div>
      </div>
    </xsl:if>

  </xsl:template>


</xsl:stylesheet>
