<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="i18n mods xlink">
  <xsl:import href="xslImport:modsmeta:metadata/mir-share.xsl" />
  <xsl:template match="/">
    <xsl:variable name="objId" select="mycoreobject/@ID" />
    <div id="mir-share">
      <div class="row">
        <div class="col-md-7">
          <!-- SocialSharePrivacy BEGIN -->
          <div class="shariff"></div>
          <!-- SocialSharePrivacy END -->
        </div>
        <div class="col-md-5">
          <!-- QR-Code BEGIN -->
          <span class="float-end d-none d-sm-block" rel="tooltip" title="QR-code for easy mobile access to this page.">
            <xsl:variable name="qrSize" select="145" />
            <img src="{$WebApplicationBaseURL}img/qrcodes/{$qrSize}/receive/{$objId}" style="min-width:{$qrSize}px" alt="QR-code for easy mobile access" />
          </span>
          <!-- QR-Code END -->
        </div>
      </div>
    </div>
    <xsl:apply-imports />
  </xsl:template>
</xsl:stylesheet>