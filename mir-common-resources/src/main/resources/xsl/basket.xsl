<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:mcri18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="mcri18n xalan">

  <xsl:template match="mycoreobject" mode="addToBasket">
    <a class="addToBasket" href="{$ServletsBaseURL}MCRBasketServlet?type=objects&amp;action=add&amp;id={@ID}&amp;uri=mcrobject:{@ID}">
      <xsl:value-of select="mcri18n:translate('basket.add')" />
    </a>
  </xsl:template>

</xsl:stylesheet>