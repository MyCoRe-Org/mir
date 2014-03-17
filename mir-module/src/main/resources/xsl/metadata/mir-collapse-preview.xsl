<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:mods="http://www.loc.gov/mods/v3" xmlns:iview="xalan://org.mycore.iview2.services.MCRIView2Tools" xmlns:xlink="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="i18n iview mods xlink">
  <xsl:import href="xslImport:modsmeta:metadata/mir-collapse-preview.xsl" />
  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="key('rights', mycoreobject/@ID)/@view">
        <xsl:if test="mycoreobject/structure/derobjects/derobject">
          <div id="mir-collapse-preview">
            <xsl:for-each select="mycoreobject/structure/derobjects/derobject[iview:isDerivateSupported(@xlink:href)]">
              <div class="panel panel-default" id="preview{@xlink:href}">
                <div class="panel-heading">
                  <h4 class="panel-title">
                    <a data-toggle="collapse" href="#collapsePrev{@xlink:href}">
                      Preview
                      <span class="caret"></span>
                    </a>
                  </h4>
                </div>
                <div id="collapsePrev{@xlink:href}" class="panel-collapse collapse in">
                  <div class="panel-body" style="margin:0;padding:0;">
                    <!-- insert preview code here -->
                  </div>
                </div>
              </div>
            </xsl:for-each>
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