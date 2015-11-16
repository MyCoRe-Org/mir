<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xalan="http://xml.apache.org/xalan"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" exclude-result-prefixes="xalan i18n">
  <xsl:param name="HttpSession" />

  <xsl:template match="mycoreobject" mode="addToBasket">
    <a class="addToBasket" href="{$ServletsBaseURL}MCRBasketServlet{$HttpSession}?type=objects&amp;action=add&amp;id={@ID}&amp;uri=mcrobject:{@ID}">
      <xsl:value-of select="i18n:translate('basket.add')" />
    </a>
  </xsl:template>

</xsl:stylesheet>