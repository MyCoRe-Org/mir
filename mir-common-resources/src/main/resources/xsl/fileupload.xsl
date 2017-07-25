<?xml version="1.0" encoding="ISO-8859-1"?>

<xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:decoder="xalan://java.net.URLDecoder"
  exclude-result-prefixes="xsl xalan i18n decoder"
>

<xsl:variable name="uploadId">
  <xsl:call-template name="UrlGetParam">
    <xsl:with-param name="url" select="$RequestURL" />
    <xsl:with-param name="par" select="'uploadId'" />
  </xsl:call-template>
</xsl:variable>
<xsl:variable name="parentObjectID">
  <xsl:call-template name="UrlGetParam">
    <xsl:with-param name="url" select="$RequestURL" />
    <xsl:with-param name="par" select="'parentObjectID'" />
  </xsl:call-template>
</xsl:variable>
<xsl:variable name="derivateID">
  <xsl:call-template name="UrlGetParam">
    <xsl:with-param name="url" select="$RequestURL" />
    <xsl:with-param name="par" select="'derivateID'" />
  </xsl:call-template>
</xsl:variable>
<xsl:variable name="cancelUrl">
  <xsl:variable name="paramValue">
    <xsl:call-template name="UrlGetParam">
      <xsl:with-param name="url" select="$RequestURL" />
      <xsl:with-param name="par" select="'cancelUrl'" />
    </xsl:call-template>
  </xsl:variable>
  <xsl:value-of select="decoder:decode(string($paramValue),'UTF-8')" />
</xsl:variable>

<xsl:param name="selectMultiple" select="'true'" />
<xsl:param name="acceptFileTypes" select="'*'" />
<xsl:param name="MCR.UploadApplet.BackgroundColor" select="'#CAD9E0'"/>
<xsl:param name="MIR.Html5Upload.Disabled" select="'false'"/>

<!-- tag to embed applet in Internet Explorer -->
<xsl:variable name="applet.object.tag">
  <object class="appletUpload" classid="clsid:8AD9C840-044E-11D1-B3E9-00805F499D93" width="380" height="130">
    <param name="uploadId" value="{$uploadId}" />
    <param name="codebase" value="{$WebApplicationBaseURL}applet" />
    <param name="code" value="org.mycore.fileupload.MCRUploadApplet.class" />
    <param name="cache_option" value="Plugin" />
    <param name="cache_archive" value="upload.jar" />
    <param name="progressbar" value="true" />
    <param name="progresscolor" value="blue" />
    <param name="background-color" value="{$MCR.UploadApplet.BackgroundColor}" />
    <param name="url" value="{$WebApplicationBaseURL}servlets/MCRUploadViaAppletServlet{$HttpSession}?method=redirecturl&amp;uploadId={$uploadId}" />
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

<xsl:template name="buildCancelUrl">
  <xsl:choose>
    <xsl:when test="string-length($cancelUrl)>0">
      <xsl:value-of select="$cancelUrl"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="concat($WebApplicationBaseURL,'receive/',$parentObjectID)"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="filetarget">
  
  <input name="uploadId" value="{$uploadId}" type="hidden"/>
  <input name="method" value="formBasedUpload" type="hidden"/>
  <xsl:variable name="cancelUrl2">
    <xsl:call-template name="buildCancelUrl" />  
  </xsl:variable>  
  <input name="cancelUrl" value="{$cancelUrl2}" type="hidden"/>
  <input name="parentObjectID" value="{$parentObjectID}" type="hidden"/>
  <input name="derivateID" value="{$derivateID}" type="hidden"/>
</xsl:template>

<xsl:template match="fileupload">
  <xsl:variable name="formUploadUrl" select="concat($WebApplicationBaseURL,'servlets/MCRUploadViaFormServlet',$HttpSession,'?method=formBasedUpload&amp;uploadId=',$uploadId)" />

  <xsl:choose>
    <xsl:when test="$MIR.Html5Upload.Disabled != 'true'">
      <div id="html5Container">
        <form id="uploadForm" action="{$formUploadUrl}" enctype="multipart/form-data" method="post">
    
          <div class="row" id="input_field">
            <div class="col-xs-12">
    
              <div class="form-group">
                <p class="help-block"><xsl:value-of select="i18n:translate('fileUpload.dropAdvice')"/></p>
                <input type="file" id="fileToUpload" name="file" onchange="fileSelected();" />
              </div>
    
              <div id="dropbox">
                <div id="files"></div>
                <h2 id="dropAdvice"><xsl:value-of select="i18n:translate('fileUpload.dropHint')"/></h2>
                <span id="fileSize" class="label label-info"></span>
              </div>
            </div>
          </div>
    
          <div class="row" id="button_row">
            <div class="col-xs-12">
              <a id="backBtn"
                      class="btn btn-primary action toggable"
                      href="{$WebApplicationBaseURL}receive/{$parentObjectID}">
                <xsl:value-of select="i18n:translate('fileUpload.back')"/>
              </a>
              <button id="clearBtn"
                      class="pull-right btn btn-primary action toggable"
                      onclick="clearFiles();" >
                <xsl:value-of select="i18n:translate('fileUpload.clear')"/>
              </button>
              <button id="cancelBtn"
                      class="pull-right btn btn-danger action toggable"
                      onclick="cancelUpload();" >
                <xsl:value-of select="i18n:translate('fileUpload.cancel')"/>
              </button>
              <button id="uploadBtn"
                      class="pull-right btn btn-success action toggable"
                      onclick="uploadFile();" >
                <xsl:value-of select="i18n:translate('fileUpload.submit')"/>
              </button>
            </div>
          </div>
    
        </form>
        <div id="progressIndicator">
    
          <div id="progressNumber" class="text-right"></div>
          <div class="progress progress-striped active">
            <div id="progressBar" class="progress-bar progress-bar-success"></div>
          </div>
          <div class="clearfix">
            <div id="transferSpeedInfo" class="pull-left"></div>
            <div id="timeRemainingInfo" class="pull-left"></div>
            <div id="transferBytesInfo" class="pull-right"></div>
          </div>
          <div id="uploadResponse">
            <div id="uploadDone">
              <p></p>
            </div>
          </div>
        </div>
      </div>
  
      <div id="appletContainer">
        <xsl:copy-of select="$applet.tag"/>
        <p>
          <xsl:value-of select="i18n:translate('fileUpload.appletInfo')" disable-output-escaping="yes" />
        </p>
      </div>
  
      <!-- load modernizr: to detect html5 and css3 capabilities -->
      <script src="{$WebApplicationBaseURL}js/fileupload/modernizr.js" type="text/javascript" />
      <!-- pre-define some variables used in the file upload javascript -->
      <script type="text/javascript">
        var formUploadUrl = '<xsl:value-of select="$formUploadUrl" />';
        var msgUploadSuccessful = '<xsl:value-of select="i18n:translate('fileUpload.success')"/>';
        var msgUploadFailed = '<xsl:value-of select="i18n:translate('fileUpload.failure')"/>';
      </script>
      <!-- show html5 upload if possible and adjust updload -->
      <script src="{$WebApplicationBaseURL}js/fileupload/fileupload.js" type="text/javascript" />
    </xsl:when>
    <xsl:otherwise>
      <div id="appletContainer" style="display: block !important">
        <xsl:copy-of select="$applet.tag"/>
        <p>
          <xsl:value-of select="i18n:translate('fileUpload.appletInfo')" disable-output-escaping="yes" />
        </p>
      </div>
    </xsl:otherwise>
  </xsl:choose>

</xsl:template>

<xsl:template match="fileupload2">
  <xsl:variable name="parameter" select="concat('&amp;parentObjectID=',$parentObjectID,'&amp;derivateID=',$derivateID)" />
  <xsl:variable name="formUploadUrl" select="concat($WebApplicationBaseURL,'servlets/MCRUploadViaFormServlet',$HttpSession,'?method=formBasedUpload&amp;uploadId=',$uploadId,$parameter)" />
  <xsl:variable name="cancelUrl2">
    <xsl:call-template name="buildCancelUrl" />  
  </xsl:variable>
  
  <xsl:choose>
    <xsl:when test="$MIR.Html5Upload.Disabled != 'true'">
      <div id="html5Container">
        <form id="uploadForm" class="form-horizontal" action="{$formUploadUrl}" enctype="multipart/form-data" method="post">
          <div class="row">
            <div class="col-md-6 col-md-offset-3">
              <p class="help-block">
                <xsl:value-of select="i18n:translate('fileUpload.dropAdvice')"/>
              </p>
              <div id="uploadResponse">
                 <div id="uploadDone" class="alert alert-warning">
                   <p></p>
                 </div>
              </div>
            </div>
            
          </div>
          <div class="form-group row" id="input_field">
            <div class="col-md-3 text-right">
              <span class="btn btn-primary btn-file">
    	        <xsl:value-of select="i18n:translate('fileupload.browse')"/>
    	        <input id="fileToUpload" name="file" onchange="fileSelected();" multiple="" type="file"/>
    	      </span>
    	    </div>
            <div id="dropbox" class="col-md-6">
              <div id="files"></div>
              <h2 id="dropAdvice"><xsl:value-of select="i18n:translate('fileUpload.dropHint')"/></h2>
              <span id="fileSize" class="label label-info"></span>
              <span id="trash" class="label label-warning" onclick="clearFiles();">
                <span class="fa fa-trash" />
              </span>
            </div>
            <div class="col-md-3">
              <xsl:variable name="helptext" select="i18n:translate('fileupload.help2')" />
              <a class="btn btn-default info-button" data-content="{$helptext}" data-placement="right" data-toggle="popover" role="button" tabindex="0">
                <i class="fa fa-info"></i>
              </a>
            </div>
          </div>
    
          <div class="formgroup row" id="button_row">
            <div class="col-md-offset-2 col-md-6">
            
              <button id="btn_back" type="button" class="btn btn-default"
                      onclick="window.location.href='{$cancelUrl2}?XSL.Status.Message=mir.derivate.editstatus.abort&amp;XSL.Status.Style=warning'" >
                <xsl:value-of select="i18n:translate('fileUpload.abort')"/>
              </button>
              <button type="button" class="btn btn-primary"
                      onclick="uploadFile();" >
                <xsl:value-of select="i18n:translate('fileUpload.submit')"/>
              </button>
              <button id="btn_done" type="button" class="btn btn-primary"
                      onclick="window.location.href='{$cancelUrl2}?XSL.Status.Message=mir.derivate.editstatus.success&amp;XSL.Status.Style=success'" disabled="true">
                <xsl:value-of select="i18n:translate('fileUpload.done')"/>
              </button>
              
            </div>
          </div>
          <fieldset>
            <legend class="mir-fieldset-legend">
              <xsl:value-of select="i18n:translate('fileUpload.uploads')"/> 
            </legend>  
            <div class="mir-fieldset-content">
              <div class="form-group">
                <div id="progressIndicator" class="col-md-6 col-md-offset-3">
                  <div id="progressNumber" class="text-right"></div>
                  <div class="progress progress-striped active">
                    <div id="progressBar" class="progress-bar progress-bar-success"></div>
                  </div>
                  <div class="clearfix">
                    <div id="transferSpeedInfo" class="pull-left"></div>
                    <div id="timeRemainingInfo" class="pull-left"></div>
                    <div id="transferBytesInfo" class="pull-right"></div>
                  </div>
                </div>
              </div>
            </div>
          </fieldset>
        </form>
      </div>
  
      <div id="appletContainer">
        <xsl:copy-of select="$applet.tag"/>
        <p>
          <xsl:value-of select="i18n:translate('fileUpload.appletInfo')" disable-output-escaping="yes" />
        </p>
      </div>
  
      <!-- load modernizr: to detect html5 and css3 capabilities -->
      <script src="{$WebApplicationBaseURL}js/fileupload/modernizr.js" type="text/javascript" />
      <!-- pre-define some variables used in the file upload javascript -->
      <script type="text/javascript">
        var formUploadUrl = '<xsl:value-of select="$formUploadUrl" />';
        var msgUploadSuccessful = '<xsl:value-of select="i18n:translate('fileUpload.success')"/>';
        var msgUploadFailed = '<xsl:value-of select="i18n:translate('fileUpload.failure')"/>';
      </script>
      <!-- show html5 upload if possible and adjust updload -->
      <script src="{$WebApplicationBaseURL}js/fileupload/fileupload.js" type="text/javascript" />
    </xsl:when>
    <xsl:otherwise>
      <div id="appletContainer" style="display: block !important">
        <xsl:copy-of select="$applet.tag"/>
        <p>
          <xsl:value-of select="i18n:translate('fileUpload.appletInfo')" disable-output-escaping="yes" />
        </p>
      </div>
    </xsl:otherwise>
  </xsl:choose>

</xsl:template>


</xsl:stylesheet>

