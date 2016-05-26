<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mcr="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:FilenameUtils="xalan://org.apache.commons.io.FilenameUtils" xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:iview2="xalan://org.mycore.iview2.frontend.MCRIView2XSLFunctions" xmlns:media="xalan://org.mycore.media.frontend.MCRXMLFunctions" xmlns:mcrsolr="xalan://org.mycore.solr.MCRXMLFunctions" xmlns:mcrsolru="xalan://org.mycore.solr.MCRSolrUtils"
  xmlns:xalan="http://xml.apache.org/xalan" exclude-result-prefixes="xalan i18n mcr media mods xlink FilenameUtils iview2 mcrxsl mcrsolr mcrsolru">
  <xsl:import href="xslImport:modsmeta:metadata/mir-video.js.xsl" />
  <xsl:param name="UserAgent" />

  <xsl:template match="/">
    <!-- MIR-339 solr query if there is any "mp4" file in this object? -->
    <xsl:variable name="solrQuery" select="concat('+stream_content_type:video/mp4 +returnId:',mcrsolru:escapeSearchValue(mycoreobject/@ID))" />
    <xsl:if test="mcrsolr:getNumFound($solrQuery) &gt; 0" >
      <div id="mir-player">
        <xsl:variable name="playerNodesTmp">
          <xsl:variable name="playerSources">
            <xsl:apply-templates select="mycoreobject/structure/derobjects/derobject" mode="optionSources" />
          </xsl:variable>

          <xsl:variable name="playerSourceNode" select="xalan:nodeset($playerSources)" />

          <xsl:if test="$playerSourceNode//source">
            <xsl:if test="count($playerSourceNode//div[@class='source-container']) > 1">
              <select id="videoChooser" class="form-control">
                <xsl:copy-of select="$playerSourceNode//optgroup" />
              </select>
              <xsl:copy-of select="$playerSourceNode//div[@class='source-container']" />
            </xsl:if>
            <div class="embed-responsive embed-responsive-16by9 mir-player mir-preview">
              <video id="player_" class="video-js embed-responsive-item" controls="" preload="auto" poster=""
                data-setup="">
                <xsl:if test="count($playerSourceNode//div[@class='source-container']) = 1">
                  <xsl:copy-of select="$playerSourceNode//div[@class='source-container']/source" />
                </xsl:if>
                <p class="vjs-no-js">
                  To view this video please enable JavaScript, and consider upgrading
                  to a web browser that
                  <a href="http://videojs.com/html5-video-support/">supports HTML5 video</a>
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
    </xsl:if>
    <xsl:apply-imports />
  </xsl:template>

  <xsl:template match="derobject" mode="optionSources">
    <!-- MIR-339 solr query if there is any "mp4" file in a derivate? -->
    <xsl:if test="key('rights', @xlink:href)/@read and mcrsolr:getNumFound(concat('+stream_content_type:video/mp4 +derivateID:',mcrsolru:escapeSearchValue(@xlink:href))) &gt; 0" >
      <xsl:variable name="ifsDirectory" select="document(concat('ifs:',@xlink:href,'/'))" />
      <xsl:apply-templates select="." mode="options">
        <xsl:with-param name="ifsDirectory" select="$ifsDirectory" />
      </xsl:apply-templates>
      <xsl:apply-templates select="." mode="sources">
        <xsl:with-param name="ifsDirectory" select="$ifsDirectory" />
      </xsl:apply-templates>
    </xsl:if>
  </xsl:template>

  <xsl:template match="derobject" mode="options">
    <xsl:param name="ifsDirectory" />
    <xsl:variable name="href" select="@xlink:href" />
    <optgroup label="{$href}">
      <xsl:for-each select="$ifsDirectory/mcr_directory/children/child">
        <xsl:if test="@type='file' and FilenameUtils:getExtension(./name) = 'mp4'">
          <option value="{$href}-{position()}">
            <xsl:value-of select="./name" />
          </option>
        </xsl:if>
      </xsl:for-each>
    </optgroup>
  </xsl:template>

  <xsl:template match="derobject" mode="sources">
    <xsl:param name="ifsDirectory" />
    <xsl:variable name="href" select="@xlink:href" />
    <xsl:for-each select="$ifsDirectory/mcr_directory/children/child">
      <xsl:if test="@type='file' and FilenameUtils:getExtension(./name) = 'mp4'">
        <div id="{$href}-{position()}" class="source-container">
          <video style="display: none;">
            <xsl:copy-of select="media:getSources($href, ./name, $UserAgent)" />
          </video>
        </div>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="addPlayerScripts">
    <xsl:param name="generatedNodes" />
    <xsl:if test="$generatedNodes//div[contains(@class, 'mir-player')]">
      <link href="//vjs.zencdn.net/5.0.0/video-js.css" rel="stylesheet" />
      <script src="//vjs.zencdn.net/ie8/1.1.0/videojs-ie8.min.js"></script>
      <style>
        /*Player Anpassungen*/
        div.vjs-control-bar{
        position: absolute;
        bottom: 0px;
        }
        div.mir-player div.panel-body{
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