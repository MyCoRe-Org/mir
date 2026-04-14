<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mets="http://www.loc.gov/METS/"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:output method="xml" encoding="utf-8" />

  <xsl:include href="resource:xslt/default-parameters.xsl" />
  <xsl:include href="xslInclude:functions" />

  <xsl:param name="MCR.Module-iview2.SupportedContentTypes" />
  <xsl:param name="objectID" />
  <xsl:param name="derivateID" select="substring-after(/mets:mets/mets:dmdSec/@ID, '_')" />
  <xsl:param name="MCR.Viewer.PDFCreatorURI" />

  <xsl:param name="ThumbnailBaseURL" select="concat($ServletsBaseURL, 'MCRDFGThumbnail/')" />
  <xsl:param name="ImageBaseURL" select="concat($ServletsBaseURL, 'MCRDFGServlet/')" />
  <xsl:param name="WebApplicationServletsURL" select="concat($WebApplicationBaseURL, 'servlets/')" />
  <xsl:param name="copyFileGrp" select="()" />

  <xsl:include href="resource:xslt/mets/mets-dfgProfile.xsl" />

</xsl:stylesheet>
