<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:mods="http://www.loc.gov/mods/v3" exclude-result-prefixes="i18n mods">
  <xsl:import href="xslImport:modsmeta:metadata/mir-collapse-preview.xsl" />
  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="key('rights', mycoreobject/@ID)/@view">
        <xsl:if test="mycoreobject/structure/derobjects/derobject">
          <div id="mir-collapse-preview">
            <div class="panel panel-default" id="preview">
              <div class="panel-heading">
                <h4 class="panel-title">
                  <a data-toggle="collapse" href="#collapseOne">
                    Preview
                    <span class="caret"></span>
                  </a>
                </h4>
              </div>
              <div id="collapseOne" class="panel-collapse collapse in">
                <div class="panel-body" style="margin:0;padding:0;">
                  <iframe id="preview-iframe" width="100%" height="400" style="border: none;"></iframe>
                </div>
              </div>
            </div>
          </div>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:comment>
          <xsl:value-of select="'mir-collapse-preview: no &quot;view&quot; permission'" />
        </xsl:comment>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-imports />
  </xsl:template>

</xsl:stylesheet>