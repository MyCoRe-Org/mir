<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mcr="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:FilenameUtils="xalan://org.apache.commons.io.FilenameUtils" xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:iview2="xalan://org.mycore.iview2.frontend.MCRIView2XSLFunctions" xmlns:media="xalan://org.mycore.media.frontend.MCRXMLFunctions"
  xmlns:mcrsolr="xalan://org.mycore.solr.MCRXMLFunctions" xmlns:mcrsolru="xalan://org.mycore.solr.MCRSolrUtils" xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:encoder="xalan://java.net.URLEncoder" exclude-result-prefixes="xalan i18n mcr media mods xlink FilenameUtils iview2 mcrxsl mcrsolr mcrsolru encoder">
  <xsl:import href="xslImport:modsmeta:metadata/mir-video.js.xsl" />
  <xsl:param name="UserAgent" />

  <xsl:template match="/">
    <!-- MIR-339 solr query if there is any "mp4" file in this object? -->
    <xsl:variable name="solrQuery"
      select="concat('+(stream_content_type:video/mp4 OR stream_content_type:audio/mpeg OR stream_content_type:audio/x-wav) +returnId:',mcrsolru:escapeSearchValue(mycoreobject/@ID))" />
    <xsl:if test="mcrsolr:getNumFound($solrQuery) &gt; 0">
      <xsl:variable name="completeQuery"
        select="concat('solr:q=', encoder:encode($solrQuery), '&amp;group=true&amp;group.field=derivateID&amp;group.limit=999')" />
      <xsl:variable name="solrResult" select="document($completeQuery)" /> <!-- [string-length(str[@name='groupValue']/text()) &gt; 0] -->
      <div id="mir-player">

        <div class="card"><!-- todo: panel-default replacement -->
        <!-- I want to make just one request, not for every derivate. So group by derivate id. -->
          <xsl:variable name="optionsFragment">
            <select id="videoChooser" class="form-control">
              <xsl:variable name="docContext" select="mycoreobject" />
              <xsl:for-each select="$solrResult/response/lst[@name='grouped']/lst[@name='derivateID']/arr[@name='groups']/lst">
                <xsl:variable name="currentDerivateID" select="str[@name='groupValue']/text()" />
                <xsl:variable name="read" select="count($docContext[key('rights', $currentDerivateID)/@read])&gt; 0" />
                <!-- TODO: maybe display derivate label instead of id -->
                <xsl:if test="$read">
                  <optgroup label="{$currentDerivateID}">
                    <xsl:apply-templates select="result/doc" mode="resultsByDerivate" />
                  </optgroup>
                </xsl:if>
              </xsl:for-each>
            </select>
          </xsl:variable>
          <xsl:variable name="options" select="xalan:nodeset($optionsFragment)" />

          <xsl:variable name="playerNode">
            <div class="embed-responsive embed-responsive-16by9 mir-player mir-preview">
              <div class="card-body">
                <xsl:if test="count($options//optgroup/option[@data-file-extension ='mp4']) &gt; 0">
                  <video id="player_video" class="video-js embed-responsive-item" controls="" preload="auto" poster="">
                    <xsl:attribute name="data-setup">{}</xsl:attribute>
                    <p class="vjs-no-js">
                      To view this video please enable JavaScript, and consider upgrading
                      to a web browser that
                      <a href="http://videojs.com/html5-video-support/">supports HTML5 video</a>
                    </p>
                  </video>
                </xsl:if>
                <xsl:if
                  test="count($options//optgroup/option[@data-file-extension ='mp3']) &gt; 0 or count($options//optgroup/option[@data-file-extension ='wav']) &gt; 0">
                  <audio id="player_audio" class="video-js embed-responsive-item" controls="" preload="auto" poster="">
                    <xsl:attribute name="data-setup">{}</xsl:attribute>
                    <p class="vjs-no-js">
                      To listen to this audio file please enable JavaScript, and consider upgrading
                      to a web browser that
                      <a href="http://caniuse.com/audio">supports HTML5 audio</a>
                    </p>
                  </audio>
                </xsl:if>
              </div>
            </div>
          </xsl:variable>

          <xsl:if test="count($options//optgroup/option) &gt; 0">
            <div class="card-heading">
              <xsl:copy-of select="$optionsFragment" />
            </div>
            <xsl:variable name="playerNodes" select="xalan:nodeset($playerNode)" />
            <xsl:call-template name="addPlayerScripts">
              <xsl:with-param name="generatedNodes" select="$playerNodes" />
            </xsl:call-template>
            <xsl:copy-of select="$playerNodes" />
          </xsl:if>

        </div>
      </div>
    </xsl:if>

    <xsl:apply-imports />

  </xsl:template>


  <xsl:template name="addPlayerScripts">
    <xsl:param name="generatedNodes" />
    <xsl:if test="$generatedNodes//div[contains(@class, 'mir-player')]">
      <link href="{$WebApplicationBaseURL}assets/videojs/css/video-js.min.css" rel="stylesheet" />
      <style>
        /*Player Anpassungen*/
        div.vjs-control-bar{
        position: absolute;
        bottom: 0px;
        }
        div.mir-player div.card-body{
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
      <script src="{$WebApplicationBaseURL}assets/videojs/js/video.min.js"></script>
      <script src="{$WebApplicationBaseURL}assets/videojs-contrib-hls/videojs-contrib-hls.min.js"></script>
    </xsl:if>
  </xsl:template>


  <xsl:template match="doc" mode="resultsByDerivate">
    <xsl:variable name="fileIFSID" select="str[@name='id']" />
    <xsl:variable name="fileMimeType" select="str[@name='stream_content_type']" />
    <xsl:variable name="filePath" select="str[@name='filePath']/text()" />
    <xsl:variable name="fileIFSPath" select="str[@name='stream_source_info']" />
    <xsl:variable name="derivateID" select="str[@name='derivateID']" />
    <xsl:variable name="fileName" select="str[@name='fileName']" />

    <xsl:variable name="lowercaseExtension"
      select="translate(FilenameUtils:getExtension($fileName), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')" />

    <xsl:comment>
      call sources
    </xsl:comment>
    <xsl:variable name="sources" select="media:getSources($derivateID, $filePath, $UserAgent)" />
    <xsl:choose>
      <xsl:when test="$fileMimeType = 'video/mp4'">
        <option data-file-extension="{$lowercaseExtension}" data-audio="false"
                data-is-main-doc="{mcr:getMainDocName($derivateID)=substring($filePath,2)}">
          <xsl:attribute name="data-sources">
            <xsl:for-each select="$sources">
              <xsl:value-of select="concat(@type, ',', @src, ';')" />
            </xsl:for-each>
          </xsl:attribute>
          <xsl:value-of select="$fileName" />
        </option>
      </xsl:when>
      <xsl:otherwise>
        <option data-file-extension="{$lowercaseExtension}" data-mime-type="{$fileMimeType}"
          data-src="{concat($ServletsBaseURL, 'MCRFileNodeServlet/', $derivateID, $filePath)}" data-audio="true"
          data-is-main-doc="{mcr:getMainDocName($derivateID)=substring($filePath,2)}">
          <xsl:value-of select="$fileName" />
        </option>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
