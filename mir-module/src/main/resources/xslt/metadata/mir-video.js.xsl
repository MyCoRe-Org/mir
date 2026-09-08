<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcracl="http://www.mycore.de/xslt/acl"
  xmlns:mcrderivate="http://www.mycore.de/xslt/derivate"
  xmlns:mcriview2="http://www.mycore.de/xslt/iview2"
  xmlns:mcrmedia="http://www.mycore.de/xslt/media"
  xmlns:mcrsolr="http://www.mycore.de/xslt/solr"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:import href="xslImport:modsmeta:metadata/mir-video.js.xsl" />

  <xsl:param name="UserAgent" />
  <xsl:param name="MIR.VideoPoster.IIIF.Resolution" select="'!1280,720'" />

  <xsl:template match="/">
    <!-- MIR-339 solr query if there is any "mp4" file in this object? -->
    <xsl:variable name="solrQuery"
      select="concat(
        '+(stream_content_type:video/mp4 OR stream_content_type:audio/mpeg OR stream_content_type:audio/x-wav OR stream_content_type:audio/vnd.wave) +returnId:',
        mcrsolr:escape-search-value(string(mycoreobject/@ID))
      )" />
    <xsl:variable name="completeQuery"
      select="concat('solr:q=', encode-for-uri($solrQuery), '&amp;group=true&amp;group.field=derivateID&amp;group.limit=999')" />
    <xsl:variable name="solrResult" select="document($completeQuery)" />

    <div id="mir-player">
      <xsl:if test="$solrResult/response/lst[@name='grouped']/lst[@name='derivateID']/arr[@name='groups']/lst/result/doc">
        <div class="card"><!-- todo: panel-default replacement -->
        <!-- I want to make just one request, not for every derivate. So group by derivate id. -->
          <xsl:variable name="optionsFragment">
            <select id="videoChooser" class="form-select">
              <xsl:variable name="docContext" select="mycoreobject" />
              <xsl:for-each select="$solrResult/response/lst[@name='grouped']/lst[@name='derivateID']/arr[@name='groups']/lst">
                <xsl:variable name="currentDerivateID" select="str[@name='groupValue']/text()" />
                <xsl:variable name="read" select="count($docContext[key('rights', $currentDerivateID)/@read]) &gt; 0" />
                <!-- TODO: maybe display derivate label instead of id -->
                <xsl:if test="$read">
                  <optgroup label="{$currentDerivateID}">
                    <xsl:apply-templates select="result/doc" mode="resultsByDerivate" />
                  </optgroup>
                </xsl:if>
              </xsl:for-each>
            </select>
          </xsl:variable>
          <xsl:variable name="options" select="$optionsFragment" />

          <xsl:variable name="playerNode">
            <div class="card-body">
              <div class="mir-player mir-preview ratio ratio-16x9">
                <xsl:if test="count($options//optgroup/option[@data-file-extension = 'mp4']) &gt; 0">
                  <video id="player_video" class="video-js" controls="" preload="auto" poster="">
                    <xsl:attribute name="data-setup">{"playbackRates":[0.5,0.75,1,1.25,1.5,1.75,2]}</xsl:attribute>
                    <p class="vjs-no-js">
                      To view this video please enable JavaScript, and consider upgrading
                      to a web browser that
                      <a href="http://videojs.com/html5-video-support/">supports HTML5 video</a>
                    </p>
                  </video>
                </xsl:if>
                <xsl:if
                  test="count($options//optgroup/option[@data-file-extension = 'mp3']) &gt; 0 or count($options//optgroup/option[@data-file-extension = 'wav']) &gt; 0">
                  <audio id="player_audio" class="video-js" controls="" preload="auto" poster="">
                    <xsl:attribute name="data-setup">{"playbackRates":[0.5,0.75,1,1.25,1.5,1.75,2]}</xsl:attribute>
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
            <xsl:variable name="playerNodes" select="$playerNode" />
            <xsl:call-template name="addPlayerScripts">
              <xsl:with-param name="generatedNodes" select="$playerNodes" />
            </xsl:call-template>
            <xsl:copy-of select="$playerNodes" />
          </xsl:if>
        </div>
      </xsl:if>
    </div>

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
        .video-js {
          position:absolute;
        }
      </style>
      <script src="{$WebApplicationBaseURL}assets/videojs/js/video.min.js"></script>
    </xsl:if>
  </xsl:template>

  <xsl:template match="doc" mode="resultsByDerivate">
    <xsl:variable name="fileMimeType" select="string(str[@name = 'stream_content_type'])" />
    <xsl:variable name="filePath" select="substring(string(str[@name = 'filePath']), 2)" />
    <xsl:variable name="derivateID" select="string(str[@name = 'derivateID'])" />
    <xsl:variable name="fileName" select="string(str[@name = 'fileName'])" />
    <xsl:variable name="lowercaseExtension" select="lower-case(mcrderivate:get-file-extension($fileName))" />

    <xsl:choose>
      <xsl:when test="$fileMimeType = 'video/mp4'">
        <option data-file-extension="{$lowercaseExtension}" data-audio="false"
          data-is-main-doc="{mcrderivate:get-main-file($derivateID) = $filePath}">
          <xsl:attribute name="data-sources">
            <xsl:variable name="sources" select="mcrmedia:get-sources($derivateID, $filePath, $UserAgent)" />
            <xsl:for-each select="$sources">
              <xsl:value-of select="concat(@type, ',', @src, ';')" />
            </xsl:for-each>
          </xsl:attribute>
          <xsl:call-template name="addPosterAttribute">
            <xsl:with-param name="derivateID" select="$derivateID" />
            <xsl:with-param name="filePath" select="$filePath" />
          </xsl:call-template>
          <xsl:value-of select="$fileName" />
        </option>
      </xsl:when>
      <xsl:otherwise>
        <option data-file-extension="{$lowercaseExtension}" data-mime-type="{$fileMimeType}"
          data-src="{concat($ServletsBaseURL, 'MCRFileNodeServlet/', $derivateID, '/', $filePath)}" data-audio="true"
          data-is-main-doc="{mcrderivate:get-main-file($derivateID) = $filePath}">
          <xsl:value-of select="$fileName" />
        </option>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Adds the iView image that was generated from a video frame as player poster. The image is only requested if the
    video file is already tiled. As the IIIF API does not share the session of the metadata page, logged in users
    need a JWT, which the player script obtains before it loads the poster.
  -->
  <xsl:template name="addPosterAttribute">
    <xsl:param name="derivateID" />
    <xsl:param name="filePath" />

    <xsl:if test="mcriview2:has-tiles($derivateID, concat('/', $filePath))">
      <xsl:variable name="posterURL"
        select="concat($WebApplicationBaseURL, 'api/iiif/image/v2/Iview/',
          encode-for-uri(concat($derivateID, '/', $filePath)), '/full/',
          $MIR.VideoPoster.IIIF.Resolution, '/0/default.jpg')" />
      <xsl:choose>
        <xsl:when test="mcracl:is-current-user-guest-user()">
          <xsl:attribute name="data-poster" select="$posterURL" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="data-poster-jwt" select="$posterURL" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
