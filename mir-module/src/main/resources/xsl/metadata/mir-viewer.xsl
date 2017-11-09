<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:mcr="xalan://org.mycore.common.xml.MCRXMLFunctions"
                xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:FilenameUtils="xalan://org.apache.commons.io.FilenameUtils"
                xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
                xmlns:iview2="xalan://org.mycore.iview2.services.MCRIView2Tools"
                xmlns:iview2xsl="xalan://org.mycore.iview2.frontend.MCRIView2XSLFunctionsAdapter"
                xmlns:embargo="xalan://org.mycore.mods.MCRMODSEmbargoUtils"
                xmlns:xalan="http://xml.apache.org/xalan"
                exclude-result-prefixes="xalan i18n mcr mods xlink FilenameUtils iview2 iview2xsl mcrxsl">
  <xsl:import href="xslImport:modsmeta:metadata/mir-viewer.xsl" />
  <xsl:param name="UserAgent" />
  <xsl:param name="MIR.DFGViewer.enable" select="'false'" />
  <xsl:param name="MCR.Viewer.PDFCreatorURI" />
  <xsl:param name="MCR.Viewer.PDFCreatorStyle" />
  <xsl:param name="MCR.Viewer.PDFCreatorFormatString" />
  <xsl:param name="MCR.Viewer.PDFCreatorRestrictionFormatString" />
  <xsl:param name="WebApplicationBaseURL" />

  <xsl:template match="/">
    <xsl:if test="mycoreobject/structure/derobjects/derobject">
      <div id="mir-viewer">
          <xsl:if test="count(mycoreobject/structure/derobjects/derobject[key('rights', @xlink:href)/@read]) > 0">
            <div class="row mir-preview">
              <div class="col-md-12">
                <h3 class="mir-viewer">Vorschau</h3>
                <!-- show one viewer for each derivate -->
                <xsl:for-each select="mycoreobject/structure/derobjects/derobject[key('rights', @xlink:href)/@read]">
                  <xsl:call-template name="createViewer" />
                </xsl:for-each>
              </div>
            </div>
          </xsl:if>
      </div>
    </xsl:if>
    <xsl:apply-imports />
  </xsl:template>

  <xsl:template name="createViewer">
    <xsl:variable name="derId" select="@xlink:href" />
    <xsl:variable name="viewerId" select="concat('viewer_',$derId)" />

    <xsl:variable name="mainFile" select="mcrxsl:getMainDocName($derId)" />

    <xsl:choose>
      <xsl:when test="iview2:getSupportedMainFile($derId)">
        <xsl:choose>
          <xsl:when test="iview2:isCompletelyTiled($derId)">
            <!-- The file will be displayed with mets -->

            <xsl:call-template name="createViewerContainer">
              <xsl:with-param name="viewerId" select="$viewerId" />
              <xsl:with-param name="viewerType" select="'mets'" />
              <xsl:with-param name="derId" select="$derId" />
            </xsl:call-template>
            <xsl:call-template name="loadViewer">
              <xsl:with-param name="viewerID" select="$viewerId" />
              <xsl:with-param name="derivate" select="$derId" />
              <xsl:with-param name="file" select="$mainFile" />
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <div class="well no-viewer">
              <xsl:value-of select="i18n:translate('metaData.previewInProcessing', $derId)" />
            </div>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="mcrxsl:getMimeType($mainFile) = 'application/pdf' and not(mcrxsl:isMobileDevice($UserAgent))">
        <xsl:call-template name="createViewerContainer">
          <xsl:with-param name="viewerId" select="$viewerId" />
          <xsl:with-param name="viewerType" select="'pdf'" />
          <xsl:with-param name="derId" select="$derId" />
        </xsl:call-template>
        <xsl:call-template name="loadViewer">
          <xsl:with-param name="viewerID" select="$viewerId" />
          <xsl:with-param name="derivate" select="$derId" />
          <xsl:with-param name="file" select="$mainFile" />
        </xsl:call-template>
        <noscript>
          <a href="{$ServletsBaseURL}MCRFileNodeServlet/{$derId}/{$mainFile}">
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
    <xsl:param name="viewerID" />
    <xsl:param name="derivate" />
    <xsl:param name="file" />
    <script>
      var baseURL = '<xsl:value-of select="$WebApplicationBaseURL" />';
      var derivate = '<xsl:value-of select="$derivate" />';
      var file = '<xsl:value-of select="$file" />';
      var viewerID = '<xsl:value-of select="$viewerID" />';

      $.get( baseURL + "rsc/viewer/" + derivate + "/" + file + "?embedded=%23" + viewerID, function( data ) {
        $(window.document.body).append(data);
      });
    </script>
  </xsl:template>


  <xsl:template name="createViewerContainer">
    <xsl:param name="viewerId" />
    <xsl:param name="viewerType" />
    <xsl:param name="derId" />

    <div id="{$viewerId}" class="viewer {$viewerType}">
    </div>

    <xsl:if test="$MIR.DFGViewer.enable='true' and  iview2xsl:hasMETSFile($derId)">
      <div class="row">
        <div id="mir-dfgViewer" class="pull-right">
          <a title="im DFG-Viewer anzeigen"
             href="{$WebApplicationBaseURL}servlets/MCRDFGLinkServlet?deriv={$derId}"
          >alternativ im<img src="{$WebApplicationBaseURL}images/logo-dfg.png" />-Viewer anzeigen
          </a>
        </div>
      </div>
    </xsl:if>

  </xsl:template>


</xsl:stylesheet>
