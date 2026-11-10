<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcracl="http://www.mycore.de/xslt/acl"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mcrpi="http://www.mycore.de/xslt/pi"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:import href="xslImport:modsmeta:mir/object-page/boxes/file-upload.xsl"/>

  <xsl:param name="MIR.Strategy.EditPIRoles" />

  <xsl:template match="/">
    <xsl:variable name="objID" select="mycoreobject/@ID"/>
    <xsl:variable name="isAllowedToEditPI"
      select="some $role in tokenize($MIR.Strategy.EditPIRoles, ',') satisfies mcracl:is-current-user-in-role($role)"/>
    <div id="mir-file-upload">
      <!-- same condition as the "add derivate" menu entry in modsdetails-external.xsl -->
      <xsl:if test="key('rights', $objID)/@write and mcracl:check-permission($objID, 'add-derivate')
        and (not(mcrpi:has-managed-pi($objID)) or $isAllowedToEditPI)">
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
