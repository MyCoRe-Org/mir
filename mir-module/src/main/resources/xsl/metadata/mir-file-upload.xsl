<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:mcri18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="mcri18n">

  <xsl:import href="xslImport:modsmeta:metadata/mir-file-upload.xsl"/>

  <xsl:template match="/">
    <xsl:variable name="objID" select="mycoreobject/@ID"/>
    <div id="mir-file-upload">
      <xsl:if test="key('rights', mycoreobject/@ID)/@write">
        <div data-upload-object="{$objID}" data-upload-target="/" data-upload-classifications="derivate_types:content">
          <xsl:choose>
            <xsl:when test="count(mycoreobject/structure/derobjects/derobject)=0">
              <xsl:attribute name="class">drop-to-object mir-file-upload-box card bg-light text-center</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="class">drop-to-object-optional mir-file-upload-box card bg-light text-center</xsl:attribute>
              <xsl:attribute name="style">display:none;</xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>
          <div class="card-body">
            <i class="fas fa-upload"></i>
            <xsl:value-of disable-output-escaping="yes" select="concat(' ', mcri18n:translate('mir.upload.drop.derivate'))"/>
          </div>  
        </div>
        <script>
          mycore.upload.enable(document.querySelector(".drop-to-object,.drop-to-object-optional").parentElement);
        </script>
      </xsl:if>
    </div>
    <xsl:apply-imports/>

  </xsl:template>

</xsl:stylesheet>
