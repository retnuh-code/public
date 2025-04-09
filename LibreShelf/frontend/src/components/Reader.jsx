import React, { useEffect, useRef } from 'react'

const Reader = () => {
  const containerRef = useRef(null)

  useEffect(() => {
    import('readium-web').then(({ createReader }) => {
      createReader({
        url: '/api/read/source/sample.epub',
        injectables: [],
        container: containerRef.current
      })
    })
  }, [])

  return <div ref={containerRef} className="w-full h-screen" />
}

export default Reader
