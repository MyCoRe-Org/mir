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
        <xsl:variable name="playerSources">
          <xsl:apply-templates select="." mode="options" />
          <xsl:apply-templates select="." mode="sources" />
        </xsl:variable>

        <xsl:variable name="playerSourceNode" select="xalan:nodeset($playerSources)" />

        <xsl:if test="$playerSourceNode//source">
          <xsl:if test="count($playerSourceNode//div[@class='source-container']) > 1">
            <select id="videoChooser" class="form-control">
              <xsl:copy-of select="$playerSourceNode//optgroup" />
            </select>
            <xsl:copy-of select="$playerSourceNode//div[@class='source-container']" />
          </xsl:if>
          <div class="embed-responsive embed-responsive-16by9 player">
            <video id="player_" class="video-js embed-responsive-item" controls="" preload="auto" poster=""
              data-setup="">
              <xsl:if test="count($playerSourceNode//div[@class='source-container']) = 1">
                <xsl:copy-of select="$playerSourceNode//div[@class='source-container']/source" />
              </xsl:if>
              <p class="vjs-no-js">
                To view this video please enable JavaScript, and consider upgrading
                to a web browser that
                <a href="http://videojs.com/html5-video-support/" target="_blank">supports
                  HTML5 video</a>
              </p>
            </video>
          </div>
        </xsl:if>
      </xsl:variable>

      <xsl:variable name="playerNodes" select="xalan:nodeset($playerNodesTmp)" />

      <xsl:call-template name="addPlayerScripts">
        <xsl:with-param name="generatedNodes" select="$playerNodes" />
      </xsl:call-template>

      <xsl:copy-of select="$playerNodes" />
    </div>
    <xsl:apply-imports />
  </xsl:template>

  <xsl:template match="derobjects/derobject" mode="options">
    <xsl:variable name="href" select="@xlink:href" />
    <xsl:if test="key('rights', $href)/@read">
      <optgroup label="{$href}">
        <xsl:variable name="ifsDirectory" select="document(concat('ifs:',$href,'/'))" />
        <xsl:for-each select="$ifsDirectory/mcr_directory/children/child">
          <xsl:variable name="fileNameExtension" select="FilenameUtils:getExtension(./name)" />
          <xsl:if test="@type='file' and $fileNameExtension = 'mp4'">
            <option value="{$href}-{position()}">
              <xsl:value-of select="./name" />
            </option>
          </xsl:if>
        </xsl:for-each>
      </optgroup>
    </xsl:if>
  </xsl:template>

  <xsl:template match="derobjects/derobject" mode="sources">
    <xsl:variable name="href" select="@xlink:href" />
    <xsl:if test="key('rights', $href)/@read">
      <xsl:variable name="ifsDirectory" select="document(concat('ifs:',$href,'/'))" />
      <xsl:for-each select="$ifsDirectory/mcr_directory/children/child">
        <xsl:variable name="fileNameExtension" select="FilenameUtils:getExtension(./name)" />
        <xsl:if test="@type='file' and $fileNameExtension = 'mp4'">
          <div id="{$href}-{position()}" class="source-container">
            <xsl:copy-of select="media:getSources($href, ./name, $UserAgent)" />
          </div>
        </xsl:if>
      </xsl:for-each>
    </xsl:if>
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
        div.video-js
        video{
        margin-bottom: -2px;
        }
      </style>
      <script src="//vjs.zencdn.net/5.0.0/video.js"></script>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>