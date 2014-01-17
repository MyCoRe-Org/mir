<?xml version="1.0" encoding="ISO-8859-1"?>

<!-- ============================================== -->
<!-- $Revision: 1.9 $ $Date: 2007-10-15 09:58:16 $ -->
<!-- ============================================== --> 

<xsl:stylesheet 
  version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
>

<xsl:param name="UploadID"/>
<xsl:param name="MCR.UploadApplet.BackgroundColor" select="'#CAD9E0'"/>
<xsl:param name="selectMultiple" select="'true'" />
<xsl:param name="acceptFileTypes" select="'*'" />

<!-- - - - - variables for starting applet - - - - -->

<xsl:variable name="applet.mime"              select="'application/x-java-applet;version=1.3.1'" />
<xsl:variable name="applet.codebase"          select="concat($WebApplicationBaseURL,'applet')" />
<xsl:variable name="applet.class"             select="'org.mycore.frontend.fileupload.MCRUploadApplet.class'" />
<xsl:variable name="applet.archives"          select="'upload.jar'" />
<xsl:variable name="applet.cache"             select="'Plugin'" />
<xsl:variable name="applet.width"             select="'380'" />
<xsl:variable name="applet.height"            select="'130'" />
<xsl:variable name="applet.nojava"            select="'In Ihrem Browser ist nicht das erforderliche Java-Plug-in installiert.'" />
<xsl:variable name="applet.netscape.plugin"   select="concat($WebApplicationBaseURL,'authoring/einrichten.xml')" />
<xsl:variable name="applet.microsoft.classid" select="'clsid:8AD9C840-044E-11D1-B3E9-00805F499D93'" />
<xsl:variable name="applet.microsoft.plugin"  select="concat($WebApplicationBaseURL,'plugins/download/j2re-1_4_0_01-windows-i586-i.exe')" />
<xsl:variable name="applet.progressbar"       select="'true'" />
<xsl:variable name="applet.progresscolor"     select="'blue'" />
<xsl:variable name="applet.background-color"  select="$MCR.UploadApplet.BackgroundColor" />

<!-- IE and NE as one tag see http://java.sun.com/products/plugin/1.2/docs/tags.html -->

<xsl:template match="fileupload">
  <xsl:variable name="url">  <!-- when applet ends this is shown --> 
    <xsl:value-of select="concat($WebApplicationBaseURL,'servlets/MCRUploadServlet',$HttpSession,'?method=redirecturl&amp;uploadId=',$UploadID)"/>
  </xsl:variable>
  <xsl:variable name="httpSession">  <!-- httpSession ID --> 
    <xsl:value-of select="substring-after($JSessionID,'=')"/>
  </xsl:variable>

  <object 
    classid  = "{$applet.microsoft.classid}"
    codebase = "{$applet.microsoft.plugin}"
    width    = "{$applet.width}" 
    height   = "{$applet.height}" >
    <param name="uploadId" value="{$UploadID}"/>

    <param name="codebase"         value="{$applet.codebase}" />
    <param name="code"             value="{$applet.class}"    />
    <param name="cache_option"     value="{$applet.cache}"    />
    <param name="cache_archive"    value="{$applet.archives}" />
    <param name="progressbar"      value="{$applet.progressbar}" />
    <param name="progresscolor"    value="{$applet.progresscolor}" />
    <param name="background-color" value="{$applet.background-color}" />
    <param name="url"              value="{$url}" />
    <param name="httpSession"      value="{$httpSession}" />
    <param name="ServletsBase"     value="{$ServletsBaseURL}" />
    <param name="selectMultiple"   value="{$selectMultiple}" />
    <param name="acceptFileTypes"  value="{$acceptFileTypes}" />
    <param name="locale"           value="{$CurrentLang}" />
        
    <noembed> <xsl:value-of select="$applet.nojava" /> </noembed>

    <comment> <!-- for netscape -->
      <xsl:element name="embed">
        <xsl:attribute name="type">             <xsl:value-of select="$applet.mime"/>            </xsl:attribute> 
        <xsl:attribute name="codebase">         <xsl:value-of select="$applet.codebase"/>        </xsl:attribute> 
        <xsl:attribute name="code">             <xsl:value-of select="$applet.class"/>           </xsl:attribute> 
        <xsl:attribute name="archive">          <xsl:value-of select="$applet.archives"/>        </xsl:attribute> 
        <xsl:attribute name="cache_option">     <xsl:value-of select="$applet.cache"/>           </xsl:attribute> 
        <xsl:attribute name="cache_archive">    <xsl:value-of select="$applet.archives"/>        </xsl:attribute> 
        <xsl:attribute name="width">            <xsl:value-of select="$applet.width"/>           </xsl:attribute> 
        <xsl:attribute name="height">           <xsl:value-of select="$applet.height"/>          </xsl:attribute> 
        <xsl:attribute name="pluginspage">      <xsl:value-of select="$applet.netscape.plugin"/> </xsl:attribute> 
        <xsl:attribute name="progressbar">      <xsl:value-of select="$applet.progressbar"/>     </xsl:attribute>
        <xsl:attribute name="progresscolor">    <xsl:value-of select="$applet.progresscolor"/>   </xsl:attribute>
        <xsl:attribute name="background-color"> <xsl:value-of select="$applet.background-color"/></xsl:attribute>
        <xsl:attribute name="uploadId">         <xsl:value-of select="$UploadID"/>               </xsl:attribute> 
        <xsl:attribute name="url">              <xsl:value-of select="$url"/>                    </xsl:attribute>
        <xsl:attribute name="httpSession">      <xsl:value-of select="$httpSession"/>            </xsl:attribute>
        <xsl:attribute name="ServletsBase">     <xsl:value-of select="$ServletsBaseURL"/>        </xsl:attribute>
        <xsl:attribute name="selectMultiple">   <xsl:value-of select="$selectMultiple"/>         </xsl:attribute>
        <xsl:attribute name="acceptFileTypes">  <xsl:value-of select="$acceptFileTypes"/>        </xsl:attribute>
        <xsl:attribute name="locale">           <xsl:value-of select="$CurrentLang"/>            </xsl:attribute>
        
        <noembed> <xsl:value-of select="$applet.nojava" /> </noembed>
       </xsl:element>
    </comment>

  </object>
</xsl:template>

</xsl:stylesheet>
