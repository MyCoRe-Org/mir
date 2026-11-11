<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template match="action[@name='imageware']" mode="object-action">
    <xsl:param name="object-id" as="xs:string" tunnel="yes" />
    <xsl:param name="write" as="xs:boolean" tunnel="yes" />

    <xsl:if test="$write and string(document(concat('callJava:org.mycore.mir.imageware.MIRImageWarePacker:displayPackerButton:', $object-id, ':ImageWare'))) = 'true'">
      <xsl:variable name="redirect" select="concat($WebApplicationBaseURL, 'receive/', $object-id, '?XSL.Status.Message=mir.iwstatus.success&amp;XSL.Status.Style=success')" />
      <li class="mir-action-item mir-action-item-display-packer-button">
        <a class="dropdown-item" href="{$ServletsBaseURL}MCRPackerServlet?packer=ImageWare&amp;objectId={$object-id}&amp;redirect={encode-for-uri($redirect)}">
          <xsl:value-of select="mcri18n:translate('object.createImagewareZipPackage')" />
        </a>
      </li>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
