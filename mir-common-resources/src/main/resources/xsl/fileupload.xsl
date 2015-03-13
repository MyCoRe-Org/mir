<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet 
  version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  exclude-result-prefixes="xsl xalan i18n"
>

<xsl:param name="UploadID" />
<xsl:param name="selectMultiple" select="'true'" /> 
<xsl:param name="acceptFileTypes" select="'*'" />
<xsl:param name="MCR.UploadApplet.BackgroundColor" select="'#CAD9E0'"/>

<!-- tag to embed applet in Internet Explorer -->
<xsl:variable name="applet.object.tag">
  <object class="appletUpload" classid="clsid:8AD9C840-044E-11D1-B3E9-00805F499D93" width="380" height="130">
    <param name="uploadId" value="{$UploadID}" />
    <param name="codebase" value="{$WebApplicationBaseURL}applet" />
    <param name="code" value="org.mycore.fileupload.MCRUploadApplet.class" />
    <param name="cache_option" value="Plugin" />
    <param name="cache_archive" value="upload.jar" />
    <param name="progressbar" value="true" />
    <param name="progresscolor" value="blue" />
    <param name="background-color" value="{$MCR.UploadApplet.BackgroundColor}" />
    <param name="url" value="{$WebApplicationBaseURL}servlets/MCRUploadServlet{$HttpSession}?method=redirecturl&amp;uploadId={$UploadID}" />
    <param name="ServletsBase" value="{$ServletsBaseURL}" />
    <param name="selectMultiple" value="{$selectMultiple}" />
    <param name="acceptFileTypes" value="{$acceptFileTypes}" />
    <noembed>
      <xsl:value-of select="i18n:translate('fileUpload.noPlugIn')" />
    </noembed>
  </object>
</xsl:variable>

<!-- tag to embed applet in both Internet Explorer and Mozilla family of browsers -->
<!-- copy the object tag and generate the embed tag from the object tag -->
<xsl:variable name="applet.tag">
  <xsl:for-each select="xalan:nodeset($applet.object.tag)/object">
    <xsl:copy>
      <xsl:copy-of select="@*|*" />
      <comment>
        <embed type="application/x-java-applet;version=1.7" pluginspage="http://java.com/download/" archive="upload.jar">
          <xsl:for-each select="param">
            <xsl:attribute name="{@name}">
              <xsl:value-of select="@value" />
            </xsl:attribute>
          </xsl:for-each>
          <xsl:copy-of select="@width|@height|noembed" />
        </embed>
      </comment>    
    </xsl:copy>
  </xsl:for-each>
</xsl:variable>

<xsl:template match="fileupload">
  <xsl:variable name="formUploadUrl" select="concat($WebApplicationBaseURL,'servlets/MCRUploadServlet',$HttpSession,'?method=formBasedUpload&amp;uploadId=',$UploadID)" />
  
  <div id="uploadContainer">
    <form id="uploadForm" action="{$formUploadUrl}" enctype="multipart/form-data" method="post">
      <div class="row">
        <label for="fileUpload"><xsl:value-of select="i18n:translate('fileUpload.dropAdvice')"/></label>
        <br />
        <input type="file" id="fileToUpload" name="file" onchange="fileSelected();" />
        <div id="dropbox">
          <div id="files"></div>
          <h2 id="dropAdvice"><xsl:value-of select="i18n:translate('fileUpload.dropHint')"/></h2>
        </div>
      </div>
      <div class="row">
        <div id="fileSize" class="label"></div>
      </div>
      <div class="row" id="buttons">
        <a onclick="uploadFile();" class="action toggable" id="uploadBtn"><xsl:value-of select="i18n:translate('fileUpload.submit')"/></a>
        <a onclick="cancelUpload();" class="action toggable" id="cancelBtn"><xsl:value-of select="i18n:translate('fileUpload.cancel')"/></a>
        <a onclick="clearFiles();" class="action toggable" id="clearBtn"><xsl:value-of select="i18n:translate('fileUpload.clear')"/></a>
        <a onclick="window.location.replace(document.referrer);" class="action toggable" id="backBtn"><xsl:value-of select="i18n:translate('fileUpload.back')"/></a>
      </div>
    </form>
    <div id="progressIndicator">
      <div id="progressBar" class="floatLeft"></div>
      <div id="progressNumber" class="floatRight"> </div>
      <div class="clear"></div>
      <div>
        <div id="transferSpeedInfo" class="floatLeft" style="width: 80px;"> </div>
        <div id="timeRemainingInfo" class="floatLeft" style="margin-left: 10px;"> </div>
        <div id="transferBytesInfo" class="floatRight" style="text-align: right;"> </div>
        <div class="clear"></div>
      </div>
      <div id="uploadResponse">
        <div id="uploadDone">
          <p style="font-weight: bold;"></p>
        </div>
      </div>
    </div>
  </div>
  
  <!-- show applet if needed, modernizr to detect drag-and-drop capability -->
  <script src="{$WebApplicationBaseURL}mir-layout/js/fileupload/modernizr.js" type="text/javascript" />
  <script type="text/javascript">
    if (!window.FileReader || !Modernizr.draganddrop) {
      document.write('<xsl:copy-of select="translate($applet.tag,'&#10;',' ')"/>');
    } 
  </script>
  <noscript>
    <xsl:copy-of select="$applet.tag"/>
  </noscript>
  
  <!-- Pre-define some variables used in the file upload javascript -->
  <script type="text/javascript">
    var formUploadUrl = '<xsl:value-of select="$formUploadUrl" />';
    var msgUploadSuccessful = '<xsl:value-of select="i18n:translate('fileUpload.success')"/>';
    var msgUploadFailed = '<xsl:value-of select="i18n:translate('fileUpload.failure')"/>';
  </script>
  <script src="{$WebApplicationBaseURL}mir-layout/js/fileupload/fileupload.js" type="text/javascript" />
</xsl:template>

</xsl:stylesheet>

