<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mcr="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:FilenameUtils="xalan://org.apache.commons.io.FilenameUtils" xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:iview2="xalan://org.mycore.iview2.frontend.MCRIView2XSLFunctions" xmlns:media="xalan://org.mycore.media.frontend.MCRXMLFunctions"
  xmlns:xalan="http://xml.apache.org/xalan" exclude-result-prefixes="xalan i18n mcr media mods xlink FilenameUtils iview2 mcrxsl">
  <xsl:import href="xslImport:modsmeta:metadata/mir-video.js.xsl" />
  <xsl:param name="UserAgent" />

  <xsl:template match="/">
    <div id="mir-player" class="player">
      <xsl:variable name="playerNodesTmp">
        <xsl:for-each select="mycoreobject/structure/derobjects/derobject">
          <!-- show one player for each derivate -->
          <xsl:variable name="derId" select="@xlink:href" />
          <xsl:variable name="derivateXML" select="document(concat('mcrobject:',$derId))" />
          <xsl:variable name="mainFile" select="$derivateXML/mycorederivate/derivate/internals/internal/@maindoc" />
          <xsl:variable name="fileNameExtension" select="FilenameUtils:getExtension($mainFile)" />

          <xsl:if test="key('rights', $derId)/@read and $fileNameExtension = 'mp4'">
            <div class="embed-responsive embed-responsive-16by9 player">
              <xsl:call-template name="createPlayer" />
            </div>
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>

      <xsl:variable name="playerNodes" select="xalan:nodeset($playerNodesTmp)" />

      <xsl:call-template name="addPlayerScripts">
        <xsl:with-param name="generatedNodes" select="$playerNodes" />
      </xsl:call-template>

      <xsl:copy-of select="$playerNodes" />
    </div>
    <xsl:apply-imports />
  </xsl:template>

  <xsl:template name="createPlayer">
    <xsl:variable name="derId" select="@xlink:href" />
    <xsl:variable name="derivateXML" select="document(concat('mcrobject:',$derId))" />
    <xsl:variable name="playerId" select="concat('player_',$derId)" />
    <xsl:variable name="mainFile" select="$derivateXML/mycorederivate/derivate/internals/internal/@maindoc" />
    <xsl:variable name="fileNameExtension" select="FilenameUtils:getExtension($mainFile)" />
    <xsl:variable name="sourcelinkURL" select="concat($WebApplicationBaseURL, 'servlets/MCRFileNodeServlet/', $derId, '/', $mainFile)" />
    <xsl:call-template name="createPlayerContainer">
      <xsl:with-param name="playerId" select="$playerId" />
      <xsl:with-param name="derId" select="$derId" />
      <xsl:with-param name="path" select="$mainFile" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="createPlayerContainer">
    <xsl:param name="playerId" />
    <xsl:param name="derId" />
    <xsl:param name="path" />
    <video id="{$playerId}" class="video-js embed-responsive-item" controls="" preload="auto" poster="" data-setup="">
      <xsl:copy-of select="media:getSources($derId, $path, $UserAgent)" />
      <p class="vjs-no-js">
        To view this video please enable JavaScript, and consider upgrading
        to a web browser that
        <a href="http://videojs.com/html5-video-support/" target="_blank">supports
          HTML5 video</a>
      </p>
    </video>
  </xsl:template>

  <xsl:template name="addPlayerScripts">
    <xsl:param name="generatedNodes" />
    <xsl:if test="$generatedNodes//div[contains(@class, 'player')]">
      <link href="//vjs.zencdn.net/5.0.0/video-js.css" rel="stylesheet" />
      <script src="//vjs.zencdn.net/ie8/1.1.0/videojs-ie8.min.js"></script>
      <style>
        /*Player Anpassungen*/
        div.vjs-control-bar{
        position: absolute;
        bottom: 0px;
        }
        div.player div.panel-body{
        padding: 0;
        }
        div.video-js
        button.vjs-big-play-button{
        left: 50%;
        margin: -0.75em 0 0 -1.5em;
        top: 50%;
        }
        div.video-js video{
        margin-bottom: -2px;
        }
      </style>
      <script src="//vjs.zencdn.net/5.0.0/video.js"></script>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>